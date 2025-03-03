alias cat="bat"
alias t="tmux"
alias vi="nvim"
alias xnvim="xargs nvim"
alias rest="timer 10m && terminal-notifier -message 'Pomodoro' -title 'Break is over\\! Get back to work 😬' -appIcon '~/Pictures/pumpkin.png' -sound Crystal"
alias work="timer 60m && terminal-notifier -message 'Pomodoro' -title 'Work Timer is up\\! Take a Break 😊' -appIcon '~/Pictures/pumpkin.png' -sound Crystal"
# eza aliases
alias l="eza -a --icons --color=always -s type -F "
alias ll="eza -l --icons --color=always -s type -F"
alias lll="eza -la --icons --color=always -s type -F"
alias ls="eza -a --icons --color=always -s type -F"
alias lt="eza -T --icons=auto --group-directories-first --hyperlink"

alias lg="lazygit"
alias ldo="lazydocker"
alias gg="git get"

alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gdiff='git diff'
alias gp="git push";
alias gs="git status";
alias gt="git tag";
alias ":q"="exit";

alias arcopen="open -n /Applications/Arc.app"

openwin() { osascript -e "tell application \"$1\" to activate" -e 'tell application "System Events" to keystroke "n" using command down'; }

lowpower(){
  pmset -a lowpoermode 1
}
