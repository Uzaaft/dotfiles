neofetch
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
function motherland
  spt play --uri https://open.spotify.com/track/0b18g3G5spr4ZCkz7Y6Q0Q
end
# if command -v spt > /dev/null
#   abbr -a motherland "spt play --uri https://open.spotify.com/track/0b18g3G5spr4ZCkz7Y6Q0Q?si=1c00ba097eca4c23"
# end
