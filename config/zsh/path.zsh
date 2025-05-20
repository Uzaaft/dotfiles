# --- configure path ---
path=(
  /opt/homebrew/opt/rustup/bin
  /opt/homebrew/opt/llvm/bin
  /opt/homebrew/bin/
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.bun/bin
  $HOME/pnpm
  $HOME/go/bin
  $HOME/.npm-global/bin
  /opt/homebrew/opt/gnu-sed/libexec/gnubin
  /opt/homebrew/opt/libpq/bin
  /opt/homebrew/opt/gnu-sed/libexec/gnubin
  $path
)

fpath=(
  /opt/homebrew/share/zsh/site-functions
  $zsh_plugins/zsh-nvim-appname
  $zsh_plugins/zig-completions
  $fpath
)
