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

# Basic auto/tab complete:
autoload -U compinit
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

_git_go() {
   local selected_path=$(fd -HI '^.git$' --max-depth 4 --type d --base-directory ${GIT_PATH} | sed 's|/.git/$||' | fzf -n 1)

    if [ -n "$selected_path" ]; then
        cd "${GIT_PATH}/$selected_path"
        # Reset the prompt
        zle reset-prompt
    else
        echo "No selection made."
        zle reset-prompt
    fi
}

# Make the function a Zle widget
zle -N _git_go

# Bind Ctrl+G to the function
bindkey '^G' _git_go



source ./path.zsh
source ./rationalise-dot.zsh
source ./aliases.zsh
source ./plugin_manager.zsh

# Load zsh-syntax-highlighting; should be last.
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
