function git_go --description 'Navigate to git repositories with fzf'
    # Depth is 5 to account for project based scopes like monorepos
    set -l selected_path (fd -HI '^.git$' --max-depth 5 --type d --base-directory $GIT_PATH | sed 's|/.git/$||' | fzf -n 1)

    if test -n "$selected_path"
        cd "$GIT_PATH/$selected_path"
        commandline -f repaint
    else
        echo "No selection made."
        commandline -f repaint
    end
end
