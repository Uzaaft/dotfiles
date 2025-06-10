export SSH_AUTH_SOCK="/Users/uzaaft/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
export GOKU_EDN_CONFIG_FILE="$HOME/.config/goku/karabiner.edn"
export NPM_CONFIG_PREFIX="/Users/uzaaft/.npm-global"
export GIT_PATH="$HOME/repositories/"
export GEM_HOME="$HOME/.gem"
export DENO_INSTALL="$HOME/.deno/"
export EDITOR="nvim"
export GEM_HOME=$HOME/.gem
export PATH=$PATH:$GEM_HOME/bin
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export BAT_THEME="Catppuccin-mocha"
export PNPM_HOME="$HOME/pnpm"

if [ -n "${NVIM_LISTEN_ADDRESS+x}" ] || [ -n "${NVIM+x}" ]; then
  export MANPAGER="nvr -c 'Man!' -o -"
else
  export MANPAGER="nvim -c 'Man!'"
fi

# NIX env stuff
export ANTHROPIC_API_KEY="op://Personal/AnthropicNeovim/credential"
export OPENAI_API_KEY="op://Polymath/OpenAI API Key/api key"

