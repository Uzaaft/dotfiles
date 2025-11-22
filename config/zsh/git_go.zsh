_git_go() {
   local selected_path=$(fd -HI '^.git$' --max-depth 5 --type d --base-directory ${GIT_PATH} | sed 's|/.git/$||' | fzf -n 1)

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
