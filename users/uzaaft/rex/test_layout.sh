#!/usr/bin/env bash
# Run with bash users/uzaaft/rex/test_layout.sh; only uses a disposable Rex server.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
tmp=$(mktemp -d)
unset REX_SESSION REX_BLOCK REX_CLIENT REX_CONFIG
export REX_SERVER="unix://$tmp/server.sock" XDG_STATE_HOME="$tmp/user-state"
export XDG_CONFIG_HOME="$tmp/config" ZDOTDIR="$tmp/config/zsh"
export SHELL="$(command -v zsh)" TERM=xterm-256color
export FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE=/dev/null MARKER="$tmp/replayed.txt"
mkdir -p "$ZDOTDIR" "$XDG_CONFIG_HOME/rex" "$tmp/one with spaces" "$tmp/two" "$tmp/three"
printf 'source %q\nPS1="ready> "\n' "$root/config/zsh/rex.zsh" >"$ZDOTDIR/.zshrc"
cp "$root/users/uzaaft/rex/init.lua" "$XDG_CONFIG_HOME/rex/init.lua"
touch "$XDG_CONFIG_HOME/rex/hosts.lua"
snapshot="$tmp/snapshot.json"
server=
cleanup() {
    if [[ -n $server ]]; then
        kill "$server" 2>/dev/null || true
        wait "$server" || true
    fi
    rm -rf "$tmp"
}
trap cleanup EXIT
wait_for() {
    for i in {1..100}; do
        if "$@"; then return 0; fi
        sleep .1
    done
    echo "Timed out: $*" >&2
    tail -30 "$tmp/server.log" >&2
    return 1
}
api() { rex --autostart=false api call "$1" "${2:-"{}"}"; }
start_server() {
    rex server run --listen "$REX_SERVER" --state-dir "$tmp/server" --restore=false \
        --config "$XDG_CONFIG_HOME/rex/init.lua" >"$tmp/server.log" 2>&1 &
    server=$!
    wait_for rex --autostart=false api call server.status '{}' >/dev/null 2>&1
}
run() { rex --autostart=false do "$root/users/uzaaft/rex/layout.lua" "action=$1" "file=$snapshot" "${@:2}"; }
count_sessions() { [[ $(api session.list | jq '.sessions | length') == "$1" ]]; }
kill_sessions() { api session.list | jq -r '.sessions[].session_id' | while read -r id; do rex kill "$id"; done; }
capture() { rex capture -s "$sid" -b "$block" --trim; }
has_prompt() { [[ $(capture) == *'ready>'* ]]; }
replayed() { [[ -f $MARKER && $(wc -l <"$MARKER") -eq "$1" ]]; }

start_server
tree=$(jq -n --arg base "$tmp" --arg shell "$SHELL" '
    def leaf($name; $dir): {block: {flavor: "com.superlogical.terminal.shell",
        label: $name, options: {cwd: ($base + "/" + $dir), shell: $shell}}};
    {label: "duplicate label", initial_windows: [
        {window_label: "Editor", layout: {split: {direction: "horizontal", ratio: 0.31,
            before: leaf("Pane 0"; "one with spaces"),
            after: {split: {direction: "vertical", ratio: 0.67,
                before: leaf("Pane 1"; "two"), after: leaf("Pane 2"; "three")}}}}},
        {window_label: "Logs", layout: leaf("Logs"; "two")},
        {window_label: "Floating", layout: leaf("Floating"; "three")}]}')
first=$(api session.create "$tree")
sid=$(jq -r .session_id <<<"$first")
block=$(jq -r '.initial_windows[0].block_ids[0]' <<<"$first")
second=$(api session.create "$(jq '{label, initial_windows: [.initial_windows[1]]}' <<<"$tree")")
api session.new_layer "$(jq -n --arg sid "$sid" --argjson tree "$tree" \
    '{session_id: $sid, bounds: [0.1,0.1,0.5,0.5], layout: $tree.initial_windows[1].layout}')" >/dev/null
api session.float_block "$(jq -n --arg sid "$sid" --arg bid "$(jq -r '.initial_windows[2].block_ids[0]' <<<"$first")" \
    '{session_id: $sid, block_id: $bid, bounds: [0.1,0.1,0.5,0.5]}')" >/dev/null
cat >"$tmp/worker.sh" <<'SH'
[[ $1 == 'argument with spaces' ]] || exit 1
pwd >>"$MARKER"
sleep 600
SH
printf -v command '%q ' bash "$tmp/worker.sh" 'argument with spaces'
rex block call -s "$sid" -b "$block" resize '{"columns":200,"rows":40}' >/dev/null
wait_for has_prompt
rex send -s "$sid" -b "$block" $'\e[200~'"$command"$'\e[201~'
rex send-key -s "$sid" -b "$block" enter
wait_for replayed 1
record="$XDG_STATE_HOME/rex-layout/running/$block.json"
jq -e --arg command "$command" '.command == $command' "$record" >/dev/null
run save
[[ $(LC_ALL=C ls -l "$snapshot" | cut -c1-10) == -rw------- ]]
jq -e --arg cwd "$tmp/one with spaces" --arg command "$command" '
    (.sessions | length) == 2 and
    (.sessions[0].initial_windows | map(.window_label)) == ["Editor", "Logs", "Floating"] and
    (.sessions[0].initial_windows[0].layout.split |
        .ratio == 0.31 and .after.split.ratio == 0.67 and
        .before.block.options.cwd == $cwd and (.before.block.options.initial_input | contains($command)))
' "$snapshot" >/dev/null
cp "$snapshot" "$tmp/original.json"
run restore
count_sessions 2
kill_sessions
run save
cmp "$snapshot" "$tmp/original.json"
run restore dry_run=true
count_sessions 0
kill "$server"; wait "$server"; server=
start_server
run restore
wait_for replayed 2
[[ $(cat "$MARKER") == "$tmp/one with spaces"$'\n'"$tmp/one with spaces" ]]
count_sessions 2
sid=$(api session.list | jq -r '.sessions[0].session_id')
view=$(rex session inspect "$sid" --json)
jq -e '.windows | map(.label) == ["Editor", "Logs", "Floating"]' <<<"$view" >/dev/null
jq -e 'all(.windows[].layers[]; .kind == "tiled") and
    (.windows[0].layers[0].layout.split | .ratio == 0.31 and .after.split.ratio == 0.67)' <<<"$view" >/dev/null
rex session rename "$sid" 'renamed restored session'
run restore
count_sessions 2
block=$(jq -r '.windows[0].layers[0].layout.split.before.block_id' <<<"$view")
record="$XDG_STATE_HOME/rex-layout/running/$block.json"
wait_for test -f "$record"
rex send-key -s "$sid" -b "$block" ctrl+c
wait_for test ! -f "$record"
run save
jq -e '.sessions[0].initial_windows[0].layout.split.before.block.options | has("initial_input") | not' "$snapshot" >/dev/null
echo 'PASS layouts, directories, quoted command replay, restart, idempotence, dry run, empty-save protection, private snapshot, interrupted-command cleanup'

kill_sessions
jq --arg cwd "$tmp/missing" '.sessions[0].initial_windows[0].layout.split.before.block.options +=
    {cwd: $cwd, initial_input: "echo unsafe\n"}' "$snapshot" >"$tmp/broken.json"
mv "$tmp/broken.json" "$snapshot"
if run restore >"$tmp/error" 2>&1; then echo 'Accepted missing directory' >&2; exit 1; fi
rg -q 'Command directory is missing' "$tmp/error"
count_sessions 0
jq '.host_id = "different-host"' "$snapshot" >"$tmp/broken.json"
mv "$tmp/broken.json" "$snapshot"
if run restore >"$tmp/error" 2>&1; then echo 'Accepted different host' >&2; exit 1; fi
rg -q 'Snapshot belongs to another Rex host' "$tmp/error"
count_sessions 0
echo 'PASS missing-directory and cross-host safeguards'

sid=$(rex new shortcut-test --json -- sleep 600 | jq -r .session_id)
popup() {
    block=$(rex do -s "$sid" show_keys | jq -r '.block_ids[0]')
    rex block call -s "$sid" -b "$block" resize '{"columns":120,"rows":35}' >/dev/null
    wait_for popup_ready
}
popup_ready() { [[ $(capture) == *'Type to filter'* ]]; }
filtered() { local screen; screen=$(capture); [[ $screen == *pane.zoom* && $screen != *pane.close* ]]; }
closed() { [[ $(rex session inspect "$sid" --json | jq '.windows[0].layers | length') == 1 ]]; }
popup
rex send -s "$sid" -b "$block" zoom
wait_for filtered
rex send-key -s "$sid" -b "$block" escape
wait_for closed
popup
rex send-key -s "$sid" -b "$block" enter
wait_for closed
echo 'PASS leader help popup, filtering, Esc and Enter dismissal'
