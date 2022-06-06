# set -gx XDG_CONFIG_HOME ~/.config
source /Users/uzaaft/.config/fish/alias.fish
source /Users/uzaaft/.config/fish/env.fish
source /Users/uzaaft/.config/fish/bangbang.fish
source /Users/uzaaft/.config/fish/prompt.fish
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

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true

test -s "$VOLTA_HOME/load.fish"; and source "$VOLTA_HOME/load.fish"
