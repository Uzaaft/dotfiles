autoload -U colors && colors
bindkey -e
PS1="%{$fg[magenta]%}%~%{$fg[red]%} %{$reset_color%}$%b "

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
alias vim=nvim

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

# Load zsh-syntax-highlighting; should be last.
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
