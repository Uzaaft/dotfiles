$env.config.show_banner = false
$env.config.highlight_resolved_externals = true

def git_go_refresh_cache [git_path: string cache_dir: string projects_cache_file: string path_cache_file: string] {
  let refresh_script = "cache_dir=\"$1\"; git_path=\"$2\"; projects_cache_file=\"$3\"; path_cache_file=\"$4\"; (mkdir -p \"$cache_dir\" && fd -HI '^\\.git$' --max-depth 5 --type d --base-directory \"$git_path\" | sed -E 's|/\\.git/?$||' | sort -u > \"$projects_cache_file.tmp\" && mv \"$projects_cache_file.tmp\" \"$projects_cache_file\" && printf '%s' \"$git_path\" > \"$path_cache_file\") >/dev/null 2>&1 &"
  ^bash -lc $refresh_script _ $cache_dir $git_path $projects_cache_file $path_cache_file
}

def --env git_go [] {
  let git_path = ($env.GIT_PATH? | default ($env.HOME | path join 'repositories'))
  if ($git_path | str trim | is-empty) {
    return
  }

  if not ($git_path | path exists) {
    return
  }

  let cache_dir = ($nu | get 'cache-dir')
  let projects_cache_file = ($cache_dir | path join 'git-go-projects.txt')
  let path_cache_file = ($cache_dir | path join 'git-go-path.txt')

  mut projects = ''
  if (($projects_cache_file | path exists) and ($path_cache_file | path exists)) {
    let cached_git_path = (open --raw $path_cache_file | str trim)
    if ($cached_git_path == $git_path) {
      $projects = (open --raw $projects_cache_file | str trim)
    }
  }

  git_go_refresh_cache $git_path $cache_dir $projects_cache_file $path_cache_file

  if ($projects | is-empty) {
    let discovered_projects_result = (
      fd -HI '^\.git$' --max-depth 5 --type d --base-directory $git_path
      | sed -E 's|/\.git/?$||'
      | ^sort -u
      | complete
    )

    if $discovered_projects_result.exit_code != 0 {
      return
    }

    $projects = ($discovered_projects_result.stdout | str trim)
    if ($projects | is-empty) {
      return
    }

    ^mkdir -p $cache_dir
    $projects | save -f $projects_cache_file
    $git_path | save -f $path_cache_file
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
