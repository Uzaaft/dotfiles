# Aliases for fish shell

# Basic aliases
alias cat bat
alias vi nvim
alias vim nvim

# eza aliases
alias l "eza -a --icons --color=always -s type -F"
alias ll "eza -l --icons --color=always -s type -F"
alias lll "eza -la --icons --color=always -s type -F"
alias ls "eza -a --icons --color=always -s type -F"
alias lt "eza -T --icons=auto --group-directories-first --hyperlink"

# Development aliases
alias lg lazygit
alias ldo lazydocker
alias gg "git get"
alias c cargo

# Git aliases
alias ga "git add"
alias gc "git commit"
alias gco "git checkout"
alias gdiff "git diff"
alias gp "git push"
alias gs "git status"
alias gt "git tag"

# Misc aliases
alias ":q" exit
alias codex "op run -- codex"