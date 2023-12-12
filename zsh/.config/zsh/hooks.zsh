# Function to check if the .git directory exists and run onefetch
check_git_and_onefetch() {
    if [[ -d ".git" ]]; then
        onefetch
    fi
}

# Set the chpwd hook to the function defined above
add-zsh-hook chpwd check_git_and_onefetch
