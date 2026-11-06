"""Run with python3 users/uzaaft/rex/test_layout.py; only uses a disposable Rex server."""

import json, os, pathlib, shutil, stat, subprocess, tempfile, time

ROOT = pathlib.Path(__file__).resolve().parents[3]
SCRIPT = ROOT / 'stowed/.local/bin/rex-layout'
NU = shutil.which('nu')
REX = shutil.which('rex')

def wait_for(fn):
    for _ in range(100):
        value = fn()
        if value:
            return value
        time.sleep(.1)
    raise AssertionError('Timed out')

with tempfile.TemporaryDirectory(prefix='rex-layout-') as temp:
    base = pathlib.Path(temp)
    env = {k:v for k,v in os.environ.items() if not k.startswith('REX_')}
    env.update(REX_SERVER='unix://' + str(base/'s.sock'), XDG_STATE_HOME=str(base/'user-state'), XDG_CONFIG_HOME=str(base/'config'), TERM='xterm-256color')
    config = base/'config/nushell/config.nu'
    config.parent.mkdir(parents=True)
    config.write_text('source ' + json.dumps(str(ROOT/'users/uzaaft/config.nu')) + '\n$env.config.history.file_format = "plaintext"\n$env.config.history.max_size = 0\n')
    def start_server():
        return subprocess.Popen([REX, 'server', 'run', '--listen', env['REX_SERVER'], '--state-dir', str(base/'server'), '--restore=false', '--config', '/dev/null'], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    server = start_server()
    try:
        wait_for(lambda: (base/'s.sock').exists())
        def rex(*args):
            return subprocess.check_output([REX, '--autostart=false', *args], env=env, text=True)
        def api(method, args={}):
            return json.loads(rex('api', 'call', method, json.dumps(args)))
        def run(action, *args, good=True):
            p = subprocess.run([NU, '--no-config-file', str(SCRIPT), action, str(base/'snapshot.json'), *args],env=env,text=True,capture_output=True)
            if good and p.returncode:
                raise AssertionError(p.stdout+p.stderr)
            if not good:
                assert p.returncode, p.stdout
            print(p.stdout.strip() or p.stderr.strip()[:160])
            return p
        dirs=[base/'one with spaces',base/'two',base/'three']
        for d in dirs: d.mkdir()
        def leaf(i):
            return {'block':{'flavor':'com.superlogical.terminal.shell','label':f'Pane {i}', 'options':{'cwd':str(dirs[i]),'shell':'none','command':[NU,'--config',str(ROOT/'users/uzaaft/config.nu'),'--env-config','/dev/null','--no-history']}}}
        tree={'split':{'direction':'horizontal','ratio':.31,'before':leaf(0),'after':{'split':{'direction':'vertical','ratio':.67,'before':leaf(1),'after':leaf(2)}}}}
        first=api('session.create',{'label':'duplicate label','initial_windows':[{'window_label':'Editor','layout':tree},{'window_label':'Logs','layout':leaf(1)},{'window_label':'Floating','layout':leaf(2)}]})
        sid=first['session_id']; block=first['initial_windows'][0]['block_ids'][0]
        second=api('session.create',{'label':'duplicate label','initial_windows':[{'layout':leaf(2)}]})
        api('session.new_layer',{'session_id':sid,'window_id':first['initial_windows'][0]['window_id'],'bounds':[.1,.1,.5,.5],'layout':leaf(0)})
        api('session.float_block',{'session_id':sid,'block_id':first['initial_windows'][2]['block_ids'][0],'bounds':[.1,.1,.5,.5]})
        # A real interactive shell runs the recorder, not a simulated record file.
        marker=base/'replayed.txt'
        worker=base/'worker.py'
        worker.write_text(f'import pathlib,time,sys\nassert sys.argv[1:] == ["argument with spaces"]\npathlib.Path({str(marker)!r}).open("a").write(str(pathlib.Path.cwd())+"\\n")\ntime.sleep(600)\n')
        command='^python3 ' + json.dumps(str(worker)) + ' "argument with spaces"'
        record=base/'user-state/rex-layout/running'/f'{block}.json'
        rex('block','call','-s',sid,'-b',block,'resize',json.dumps({'columns':200,'rows':40}))
        time.sleep(2)
        rex('send','-s',sid,'-b',block,'\x1b[200~'+command+'\x1b[201~')
        time.sleep(.5)
        rex('send-key','-s',sid,'-b',block,'enter')
        try:
            wait_for(lambda: marker.exists())
        except AssertionError:
            print(rex('capture','-s',sid,'-b',block,'--trim'))
            raise
        assert record.exists(), rex('capture','-s',sid,'-b',block,'--trim')
        recorded=json.loads(record.read_text())
        assert recorded['command']==command, recorded
        print('PASS real pre-execution recorder and quoted command')
        run('save')
        snap=json.loads((base/'snapshot.json').read_text())
        assert stat.S_IMODE((base/'snapshot.json').stat().st_mode)==0o600
        assert len(snap['sessions'])==2
        saved=snap['sessions'][0]['initial_windows'][0]['layout']
        assert saved['split']['ratio']==.31
        assert saved['split']['after']['split']['ratio']==.67
        options=saved['split']['before']['block']['options']
        assert options['cwd']==str(dirs[0]) and command in options['initial_input'],options
        assert [w['window_label'] for w in snap['sessions'][0]['initial_windows']]==['Editor','Logs','Floating']
        run('restore')
        assert len(api('session.list')['sessions'])==2
        rex('kill',sid);rex('kill',second['session_id'])
        run('save')
        assert json.loads((base/'snapshot.json').read_text())==snap
        run('restore','--dry-run')
        assert not api('session.list')['sessions']
        # Restart the disposable server too, not only its sessions.
        server.terminate()
        server.wait(timeout=8)
        server = start_server()
        wait_for(lambda: subprocess.run([REX,'--autostart=false','api','call','server.status','{}'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode == 0)
        run('restore')
        try:
            wait_for(lambda: len(marker.read_text().splitlines())==2)
        except AssertionError:
            current=api('session.list')['sessions'][0]['session_id']
            bv=api('session.view',{'session_id':current})['windows'][0]['layers'][0]['blocks'][0]['block_id']
            print(rex('capture','-s',current,'-b',bv,'--trim'))
            raise
        assert marker.read_text().splitlines()==[str(dirs[0].resolve())]*2, marker.read_text()
        live=api('session.list')['sessions']
        assert len(live)==2
        view=api('session.view',{'session_id':live[0]['session_id']})
        assert [w['label'] for w in view['windows']]==['Editor','Logs','Floating']
        restored_tree=view['windows'][0]['layers'][0]['layout']
        assert restored_tree['split']['ratio']==.31 and restored_tree['split']['after']['split']['ratio']==.67
        assert all(layer['kind']=='tiled' for window in view['windows'] for layer in window['layers'])
        rex('session','rename',live[0]['session_id'],'renamed restored session')
        run('restore')
        assert len(api('session.list')['sessions'])==2
        print('PASS nested splits, tab order, labels, directories, floating omission, command replay, rename-safe idempotence, dry run, empty-save protection, private snapshot')
        # Interrupting the resumed command returns to a prompt and clears its record.
        newblock=restored_tree['split']['before']['block_id']
        newrecord=base/'user-state/rex-layout/running'/f'{newblock}.json'
        wait_for(lambda: newrecord.exists())
        rex('send-key','-s',live[0]['session_id'],'-b',newblock,'ctrl+c')
        wait_for(lambda: not newrecord.exists())
        run('save')
        snap=json.loads((base/'snapshot.json').read_text())
        assert 'initial_input' not in snap['sessions'][0]['initial_windows'][0]['layout']['split']['before']['block']['options']
        print('PASS completed/interrupted commands are not replayed')
        # Missing replay directories fail without creating sessions.
        for s in api('session.list')['sessions']: rex('kill',s['session_id'])
        broken=json.loads(json.dumps(snap)); broken['sessions'][0]['initial_windows'][0]['layout']['split']['before']['block']['options'].update(cwd=str(base/'missing'),initial_input='echo unsafe\n')
        (base/'snapshot.json').write_text(json.dumps(broken))
        run('restore',good=False)
        assert not api('session.list')['sessions']
        broken['host_id']='different-host'; (base/'snapshot.json').write_text(json.dumps(broken))
        run('restore',good=False)
        assert not api('session.list')['sessions']
        print('PASS missing-directory and cross-host safeguards')
    finally:
        server.terminate()
        try: server.wait(timeout=8)
        except subprocess.TimeoutExpired: server.kill();server.wait()
