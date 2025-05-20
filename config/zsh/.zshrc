autoload -U colors && colors
bindkey -e
PS1="%{$fg[magenta]%}%~%{$fg[red]%} %{$reset_color%}$%b "

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

# --- completion ---
autoload -Uz compinit
zmodload zsh/complist
comp_cache=${zsh_cache}/zcompdump-${ZSH_VERSION}
_comp_options+=(globdots)		# Include hidden files.
compinit -d ${comp_cache}
[[ ${comp_cache}.zwc -nt ${comp_cache} ]] || zcompile -R -- "${comp_cache}".zwc "${comp_cache}" # compile completion  cache

source $ZDOTDIR/git_go.zsh
source $ZDOTDIR/path.zsh
source $ZDOTDIR/rationalise-dot.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/plugin_manager.zsh

source <(fzf --zsh)
source ./path.zsh
source ./rationalise-dot.zsh
source ./aliases.zsh
source ./plugin_manager.zsh

eval "$(direnv hook zsh)"
# Load zsh-syntax-highlighting; should be last.
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
