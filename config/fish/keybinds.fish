function gitgo
    # Run the command and capture the selected path
    set -l selected_path (fd -HI '^.git$' --max-depth 4 --type d --base-directory $GIT_PATH | sed 's|/.git/$||' | fzf -n 1)
    echo $selected_path

    # Check if a path was selected
    if test -n "$selected_path"
        # Change to the selected directory
        cd "$GIT_PATH/$selected_path"
    end
    commandline -f repaint
end

bind ctrl-g gitgo
