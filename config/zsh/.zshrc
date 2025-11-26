# --- powerlevel10k instant prompt ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -U colors && colors
bindkey -v
# PS1="%{$fg[magenta]%}%~%{$fg[red]%} %{$reset_color%}$%b "

# Settings
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
export HISTSIZE=1000000
export HISTFILE="${XDG_STATE_HOME-$HOME/.local/state}/zsh/history"
export SAVEHIST=1000000
export KEYTIMEOUT=10

# --- zsh data directories ---
zsh_data="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
[ ! -d ${zsh_data} ] && mkdir -p ${zsh_data}
zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[ ! -d ${zsh_cache} ] && mkdir -p ${zsh_cache}
zsh_plugins="${zsh_data}/plugins"
[ ! -d ${zsh_plugins} ] && mkdir -p ${zsh_plugins}

source $ZDOTDIR/plugin_manager.zsh

# --- completion ---
function load_completion() {
  autoload -Uz compinit
  zmodload zsh/complist
  comp_cache=${zsh_cache}/zcompdump-${ZSH_VERSION}
  _comp_options+=(globdots)		# Include hidden files.
  compinit -d ${comp_cache}
  [[ ${comp_cache}.zwc -nt ${comp_cache} ]] || zcompile -R -- "${comp_cache}".zwc "${comp_cache}" # compile completion  cache

  source <(fzf --zsh)

  # --- fzf-tab ---
  source ${zsh_plugins}/fzf-tab/fzf-tab.plugin.zsh
  # download preview script if it doesn't exist
  if [ ! -f ${HOME}/.local/bin/preview ]; then
    mkdir -p ${HOME}/.local/bin
    wget -O ${HOME}/.local/bin/preview -- \
      https://gist.githubusercontent.com/mehalter/2809925b6e266b3574c7deab3dae711a/raw/6dd84d6bf8167ed9dd60adc6e64b7e765017341b/preview
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

  eval "$(direnv hook zsh)"
}
zsh-defer load_completion

source $ZDOTDIR/git_go.zsh
source $ZDOTDIR/path.zsh
source $ZDOTDIR/rationalise-dot.zsh
source $ZDOTDIR/aliases.zsh
# Load zsh-syntax-highlighting; should be last.
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- powerlevel10k prompt ---
source ${zsh_plugins}/powerlevel10k/powerlevel10k.zsh-theme
[ -f ${ZDOTDIR:-$HOME}/.p10k.zsh ] && source ${ZDOTDIR:-$HOME}/.p10k.zsh
