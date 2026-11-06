use std/config *

$env.config.show_banner = false
$env.config.highlight_resolved_externals = true

# rex-layout only replays commands still running when a snapshot is taken.
def rex-command-file [] {
  if $env.REX_BLOCK? == null { return null }
  $env.XDG_STATE_HOME? | default ($env.HOME | path join .local state)
  | path join rex-layout running $'($env.REX_BLOCK).json'
}

$env.config.hooks.pre_execution = ($env.config.hooks.pre_execution | append {||
  try {
    let file = (rex-command-file)
    if $file != null {
      let parent = ($file | path dirname)
      if not ($parent | path exists) { mkdir $parent; ^chmod 700 $parent }
      {pid: $nu.pid, shell: $nu.current-exe, cwd: $env.PWD, command: (commandline)}
      | to json | save --force $file
    }
  } catch { }
})

$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {||
  try {
    let file = (rex-command-file)
    if $file != null and ($file | path exists) {
      if (open --raw $file | from json).pid == $nu.pid { rm $file }
    }
  } catch { }
})

def --env git_go [] {
  let git_path = ($env.GIT_PATH? | default ($env.HOME | path join 'repositories'))
  if ($git_path | str trim | is-empty) {
    return
  }

  if not ($git_path | path exists) {
    return
  }

  let discovered_projects_result = (
    fd -HI '^\.git$' --max-depth 5 --type d --base-directory $git_path
    | sed -E 's|/\.git/?$||'
    | ^sort -u
    | complete
  )

  if $discovered_projects_result.exit_code != 0 {
    return
  }

  let projects = ($discovered_projects_result.stdout | str trim)
  if ($projects | is-empty) {
    return
  }

  let selected_path_result = (
    $projects
    | fzf -n 1
    | complete
  )

  if $selected_path_result.exit_code != 0 {
    return
  }

  let selected_path = ($selected_path_result.stdout | str trim)

  if ($selected_path | is-not-empty) {
    cd ($git_path | path join $selected_path)
  }
}

def --env rationalise_dot [] {
  let line_buffer = (commandline)
  let cursor_position = (commandline get-cursor)
  let left_buffer = ($line_buffer | str substring 0..<$cursor_position)
  let right_buffer = ($line_buffer | str substring $cursor_position..)

  let insertion = if ($left_buffer =~ '(^|/| |\t|\n|\||;|&)\.\.$') {
    '/..'
  } else {
    '.'
  }

  commandline edit --replace ($left_buffer + $insertion + $right_buffer)
  commandline set-cursor ($cursor_position + ($insertion | str length))
}

# Homebrew setup
if ('/opt/homebrew' | path type) == 'dir' {
  $env.HOMEBREW_PREFIX = '/opt/homebrew'
  $env.HOMEBREW_CELLAR = '/opt/homebrew/Cellar'
  $env.HOMEBREW_REPOSITORY = '/opt/homebrew'
  $env.PATH = $env.PATH? | prepend [
    '/opt/homebrew/bin'
    '/opt/homebrew/sbin'
  ]
  $env.MANPATH = ($env.MANPATH? | default '' | split row ':' | prepend '/opt/homebrew/share/man' | str join ':')
  $env.INFOPATH = ($env.INFOPATH? | default '' | split row ':' | prepend '/opt/homebrew/share/info' | str join ':')
}

$env.config.keybindings = $env.config.keybindings | append [
  {
    name: git_go
    modifier: control
    keycode: char_g
    mode: [emacs vi_insert vi_normal]
    event: {
      send: executehostcommand
      cmd: 'git_go'
    }
  }
  {
    name: autosuggest_accept
    modifier: control
    keycode: space
    mode: [emacs vi_insert]
    event: {
      send: historyhintcomplete
    }
  }
  {
    name: rationalise_dot
    modifier: none
    keycode: char_.
    mode: [emacs vi_insert]
    event: {
      send: executehostcommand
      cmd: 'rationalise_dot'
    }
  }
]

# Ensure we can use the terminal for GPG signing
if (is-terminal --stdin) {
  $env.GPG_TTY = (tty)
}
