$env.config.show_banner = false
$env.config.highlight_resolved_externals = true

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
        name: completion_menu
        modifier: control
        keycode: char_g
        mode: emacs
          event:[
          { edit: Clear }
          { edit: InsertString,
            value: "cd $env.GITPATH/(fd -HI '^.git$' --max-depth 4 --type d --base-directory $env.GIT_PATH | sed 's|/.git/$||' | fzf -n 1)"
          }
          { send: Enter }
        ]
    }
]

# Ensure we can use the terminal for GPG signing
if (is-terminal --stdin) {
  $env.GPG_TTY = (tty)
}
