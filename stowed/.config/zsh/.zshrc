# zmodload zsh/zprof

# assumed commands:
#   git (plugin management)
#   wget (downloading  preview script)
#   bat (tab preview)
#   delta (tab preview)
#   w3m (tab preview)
#   bsdtar (tab preview)
#   jq (tab preview)
#   mediainfo (tab preview)
#   odt2txt (tab preview)

# --- powerlevel10k instant prompt ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- zsh data directories ---
zsh_data="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
[ ! -d ${zsh_data} ] && mkdir -p ${zsh_data}
zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[ ! -d ${zsh_cache} ] && mkdir -p ${zsh_cache}
zsh_plugins="${zsh_data}/plugins"
[ ! -d ${zsh_plugins} ] && mkdir -p ${zsh_plugins}

# --- minimal zsh plugin manager ---
function zsh_install_missing_plugins() {
  function zcompile-many() { local f; for f; do zcompile -R -- "$f".zwc "$f"; done }
  function clone-plugin() {
    local plugin="$(basename ${1})"
    echo "Installing ${plugin}"
    git clone --quiet --depth=1 "${1}.git" ${zsh_plugins}/${plugin} > /dev/null
  }
  # clone plugins, add more plugin downloads here with optional compilation calls to improve startup
  if [[ ! -e ${zsh_plugins}/zsh-completions ]]; then
    clone-plugin "https://github.com/zsh-users/zsh-completions"
  fi
  if [[ ! -e ${zsh_plugins}/fzf-tab ]]; then
    clone-plugin "https://github.com/Aloxaf/fzf-tab"
    zcompile-many ${zsh_plugins}/fzf-tab/*.zsh
  fi
  if [[ ! -e ${zsh_plugins}/zsh-syntax-highlighting ]]; then
    clone-plugin "https://github.com/zsh-users/zsh-syntax-highlighting"
    zcompile-many ${zsh_plugins}/zsh-syntax-highlighting/{zsh-syntax-highlighting.zsh,highlighters/*/*.zsh}
  fi
  if [[ ! -e ${zsh_plugins}/zsh-autosuggestions ]]; then
    clone-plugin "https://github.com/zsh-users/zsh-autosuggestions"
    zcompile-many ${zsh_plugins}/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
  fi
  if [[ ! -e ${zsh_plugins}/powerlevel10k ]]; then
    clone-plugin "https://github.com/romkatv/powerlevel10k"
    make -C ${zsh_plugins}/powerlevel10k pkg > /dev/null || echo "Error building powerlevel10k"
  fi
  if [[ ! -e ${zsh_plugins}/zsh-nvim-appname ]]; then
    clone-plugin "https://github.com/mehalter/zsh-nvim-appname"
    zcompile-many ${zsh_plugins}/zsh-nvim-appname/zsh-nvim-appname.plugin.zsh
  fi

  unfunction zcompile-many clone-plugin
}
# --- zsh plugin manager updater ---
function zsh_update_plugins() { rm -rf ${zsh_plugins}/**; zsh_install_missing_plugins }

# --- install zsh plugins ---
zsh_install_missing_plugins

# --- configure zsh options ---
setopt autocd
setopt bash_rematch
setopt correct
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history
setopt interactivecomments
export HISTIGNORE="&:ls:[bf]g:exit:reset:clear:cd:cd ..:cd.."
export HISTSIZE=25000
export HISTFILE="${XDG_STATE_HOME-$HOME/.local/state}/zsh/history"
export SAVEHIST=10000
export KEYTIMEOUT=10

# --- setup fzf ---
export FZF_HOME=${XDG_CONFIG_HOME:-$HOME/.config}/fzf
if [ ! -d ${FZF_HOME} ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ${FZF_HOME}
  ${FZF_HOME}/install --xdg --no-update-rc
fi
function zsh_update_fzf() {
  if test "$(git -C ${FZF_HOME} rev-parse HEAD)" = "$(git -C ${FZF_HOME} rev-parse master)"; then
    echo "No updates for FZF"
  else
    echo "Pulling the latest FZF..."
    git -C ${FZF_HOME} reset --hard master
    git -C ${FZF_HOME} pull
    echo "Updating FZF..."
    ${FZF_HOME}/install
  fi
}
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh
export FZF_DEFAULT_OPTS="--extended"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# --- completion ---
source $ZDOTDIR/brew.zsh
source $ZDOTDIR/alias.zsh
autoload -Uz compinit
comp_cache=${zsh_cache}/zcompdump-${ZSH_VERSION}
compinit -d ${comp_cache}
[[ ${comp_cache}.zwc -nt ${comp_cache} ]] || zcompile -R -- "${comp_cache}".zwc "${comp_cache}" # compile completion  cache
zstyle ':completion:*' cache-path ${zsh_cache} # cache path
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # use ls colors
zstyle ':completion:*' completer _complete # approximate completion matches
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*' # case insensitive, partial word, substring
zstyle ':completion::complete:*' use-cache 1 # use cache
zstyle ':completion:*:git-checkout:*' sort false # don't sort git checkout
zstyle ':completion:*:descriptions' format '[%d]' # enable group supported descriptions

# === PLUGINS ===

# --- fzf-tab ---
source ${zsh_plugins}/fzf-tab/fzf-tab.plugin.zsh
# download preview script if it doesn't exist
if [ ! -f ${HOME}/.local/bin/preview ]; then
  mkdir -p ${HOME}/.local/bin
  wget -O ${HOME}/.local/bin/preview -- \
    https://gist.githubusercontent.com/mehalter/2809925b6e266b3574c7deab3dae711a/raw/1d8f001c871af3bfc5139260ed7f1301929df15a/preview
  chmod +x ${HOME}/.local/bin/preview
fi
zstyle ':fzf-tab:*' switch-group ',' '.' # switch groups with ,/.
zstyle ':fzf-tab:complete:*:options' fzf-preview  # disable options preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview # disable subcommand preview
zstyle ':fzf-tab:complete:(nvapp|pg|pd|pe|td|te):*' fzf-preview # disable preview for my own zsh completion
zstyle ':fzf-tab:complete:-command-:*' fzf-preview '(out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "${(P)word}"'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'preview ${(Q)realpath}'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
  'case "$group" in
  "commit tag") git show --color=always $word ;;
  *) git show --color=always $word | delta ;;
  esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
  "modified file") git diff $word | delta ;;
  "recent commit object name") git show --color=always $word | delta ;;
  *) git log --color=always $word ;;
  esac'

# --- zsh-syntax-highlighting ---
source ${zsh_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- zsh-autosuggestions ---
source ${zsh_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- powerlevel10k prompt ---
source ${zsh_plugins}/powerlevel10k/powerlevel10k.zsh-theme
[ -f ${ZDOTDIR:-$HOME}/.p10k.zsh ] && source ${ZDOTDIR:-$HOME}/.p10k.zsh

# --- zsh-nvim-appname ---
source ${zsh_plugins}/zsh-nvim-appname/zsh-nvim-appname.plugin.zsh

# === END PLUGINS ===
#
# -- Custom Uzaaft keybinding
git_go() {
  target=`git_cd`
   [[ ! -z "$target" ]] && builtin cd "$target" ||
  zle reset-prompt;
}
config_go() {
  target=`config_cd`
  [[ ! -z "$target" ]] && builtin cd "$target" ||
    zle reset-prompt
}
zle -N git_go
zle -N config_go

# --- keybindings ---
autoload -Uz edit-command-line
function zle-keymap-select() { zle reset-prompt; zle -R }
zle -N edit-command-line
zle -N zle-keymap-select
bindkey -v
if [[ $TERM == tmux* ]]; then
  bindkey '^[[1~' beginning-of-line
  bindkey '^[[4~' end-of-line
else
  bindkey '^[[H' beginning-of-line
  bindkey '^[[F' end-of-line
fi
bindkey '^[[3~' delete-char
bindkey -M viins '^a' vi-beginning-of-line
bindkey -M viins '^e' vi-end-of-line
bindkey -M viins '^k' kill-line
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward
bindkey "^?" backward-delete-char
bindkey '^x^e' edit-command-line
bindkey '^ ' autosuggest-accept
bindkey "^g" git_go
bindkey "ç" config_go

# expand ... to ../.. recursively
function _rationalise-dot { # This was written entirely by Mikael Magnusson (Mikachu)
  local MATCH # keep the regex match from leaking to the environment
  if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert
  else
    zle self-insert
  fi
}
zle -N _rationalise-dot
bindkey . _rationalise-dot
bindkey -M isearch . self-insert # without this, typing . aborts incr history search

# --- configure path ---
path=(
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
# source env.zsh
source $ZDOTDIR/env.zsh

# Colorful sudo prompt.
SUDO_PROMPT="$(tput setaf 2 bold)Password: $(tput sgr0)" && export SUDO_PROMPT

# --- source various other scripts ---
# source ${ZDOTDIR:-$HOME}/.aliases

# --- miscellaneous ---
# # configure nvim as manpager (requires neovim-remote)
#
# opam configuration
[[ ! -r /Users/uzaaft/.opam/opam-init/init.zsh ]] || source /Users/uzaaft/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
FPATH="$zsh_plugins/zsh-nvim-appname:${FPATH}"

eval "$(/opt/homebrew/bin/mise activate zsh)"

# pnpm
export PNPM_HOME="/Users/uzaaft/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# zprof

# bun completions
[ -s "/Users/uzaaft/.bun/_bun" ] && source "/Users/uzaaft/.bun/_bun"
