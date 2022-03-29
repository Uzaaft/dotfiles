source ~/.config/fish/prompt.fish
source ~/.config/fish/alias.fish
source ~/.config/fish/env.fish
source ~/.config/fish/bangbang.fish
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
    end
end


thefuck --alias | source

set -gx COLORTERM "truecolor"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

