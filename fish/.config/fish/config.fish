# set -gx XDG_CONFIG_HOME ~/.config
source $HOME/.config/fish/alias.fish
source $HOME/.config/fish/env.fish
source $HOME/.config/fish/bangbang.fish
source $HOME/.config/fish/prompt.fish
if command -v pazi >/dev/null
  status --is-interactive; and pazi init fish | source
end
if command -v zoxide > /dev/null
  zoxide init fish | source
end




# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" "hook" $argv | source 
# <<< conda initialize <<<
starship init fish | source
