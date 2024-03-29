export NPM_CONFIG_PREFIX="/Users/uzaaft/.npm-global"

# OLD Path stuff
# export PATH="$GEM_HOME/bin:$PATH"
# export PATH="$DENO_INSTALL/bin:$PATH"

# export TMUX_CONFIG_DIR="/Users/uzaaft/.config/tmux"
# export TERM="wezterm"
export GIT_PATH="$HOME/repositories/"
export GEM_HOME="$HOME/.gem"
export DENO_INSTALL="$HOME/.deno/"
export EDITOR="nvim"

export XDG_CONFIG_HOME="$HOME/.config"
# export RUSTC_WRAPPER="$(which sccache)"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export BAT_THEME="Catppuccin-mocha"

export PNPM_HOME="$HOME/pnpm"

if [ -n "${NVIM_LISTEN_ADDRESS+x}" ] || [ -n "${NVIM+x}" ]; then
  export MANPAGER="nvr -c 'Man!' -o -"
else
  export MANPAGER="nvim -c 'Man!'"
fi
