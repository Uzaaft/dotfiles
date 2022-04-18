# set -gx XDG_CONFIG_HOME ~/.config
source ~/.config/fish/alias.fish
source ~/.config/fish/env.fish
source ~/.config/fish/bangbang.fish
source ~/.config/fish/upgrade.fish
source ~/.config/fish/prompt.fish
if command -v pazi >/dev/null
  status --is-interactive; and pazi init fish | source
end
if command -v zoxide > /dev/null
  zoxide init fish | source
end

function cd
  builtin cd $argv
    if test -d .git
      onefetch
      git fetch > /dev/null
    end
end


thefuck --alias | source


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true

