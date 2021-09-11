abbr -a yr 'cal -y'
abbr -a c cargo
abbr -a e lvim
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

source ~/.config/fish/prompt.fish
source ~/.config/fish/env.fish
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
