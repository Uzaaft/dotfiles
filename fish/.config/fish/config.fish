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

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

# pnpm
set -gx PNPM_HOME "/Users/uzaaft/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end