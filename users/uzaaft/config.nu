use std/config *

$env.config.show_banner = false
$env.config.highlight_resolved_externals = true

# Run direnv only when changing directories, matching Nushell's recommended integration.
$env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []
$env.config.hooks.env_change.PWD ++= [
  {||
    if (which direnv | is-empty) {
      return
    }

    direnv export json | from json | default {} | load-env
    $env.PATH = do (env-conversions).path.from_string $env.PATH
  }
]

let starship_autoload_dir = (($nu | get 'data-dir') | path join 'vendor' 'autoload')
let starship_autoload = ($starship_autoload_dir | path join 'starship.nu')

if ((which starship | length) > 0) {
  mkdir $starship_autoload_dir
  starship init nu | save -f $starship_autoload
}

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
  $env.MANPATH = $env.MANPATH? | prepend '/opt/homebrew/share/man'
  $env.INFOPATH = $env.INFOPATH? | prepend '/opt/homebrew/share/info'
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

alias atc = amp threads continue
alias lg = lazygit
