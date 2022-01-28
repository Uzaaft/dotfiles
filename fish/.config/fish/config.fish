abbr -a yr 'cal -y'
abbr -a c cargo
abbr -a e lvim
abbr -a vi lvim
abbr -a pr 'gh pr create -t (git show -s --format=%s HEAD) -b (git show -s --format=%B HEAD | tail -n+3)'
if command -v exa > /dev/null
	abbr -a l 'exa'
	abbr -a ls 'exa'
	abbr -a ll 'exa -l'
	abbr -a lll 'exa -la'
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
end

if command -v fd > /dev/null
  abbr -a find "fd"
else
  abbr -a find "find"
end

if command -v rg > /dev/null
  abbr -a grep "rg"
else
  abbr -a grep "grep"
end

source ~/.config/fish/prompt.fish
source ~/.config/fish/env.fish
source ~/.config/fish/bangbang.fish
if command -v pazi >/dev/null
  status --is-interactive; and pazi init fish | source
end

function cd
  builtin cd $argv
    if test -d .git
      onefetch
    end
end
thefuck --alias | source
set -gx PATH $HOME/lib/miniconda/bin $PATH



# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

