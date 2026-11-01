_git_go() {
    local selected_path
    selected_path="$("$HOME/.local/bin/git-project")"

    if [ -n "$selected_path" ]; then
        cd "$selected_path"
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
