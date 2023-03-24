export NPM_CONFIG_PREFIX="/Users/uzaaft/.npm-global"

# Path stuff
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin/:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/tools:$PATH"
export PATH="$ANDROID_HOME/tools/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/dotfiles/jetbrains_ide:$PATH"
export PATH="$GEM_HOME/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="$HOME/.local/share/neovim/bin/:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

export ANDROID_HOME="$HOME/Library/Android/Sdk"
export TMUX_CONFIG_DIR="/Users/uzaaft/.config/tmux"
export TERM="wezterm"
export TERM="xterm-256color"
export SCCACHE_SIZE="50G"
export GEM_HOME="$HOME/.gem"
export VOLTA_HOME="$HOME/.volta"
export DENO_INSTALL="$HOME/.deno/"
export VOLTA_HOME="$HOME/.volta"
export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export RUSTC_WRAPPER="$(which sccache)"


export PATH="$HOME/pnpm:$PATH"
export PNPM_HOME="$HOME/pnpm"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
