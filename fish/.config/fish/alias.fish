abbr -a yr 'cal -y'
abbr -a c cargo
abbr -a e lvim
abbr -a pr 'gh pr create -t (git show -s --format=%s HEAD) -b (git show -s --format=%B HEAD | tail -n+3)'
abbr -a vi "lvim"
abbr -a pa "ls | xargs -P10 -I{} git -C {} pull"
abbr -a clc "clear"
if command -v exa > /dev/null
	abbr -a l 'exa -a --icons --color=always -s type -F '
	abbr -a ls 'exa -a --icons --color=always -s type -F'
	abbr -a ll 'exa -l --icons --color=always -s type -F'
	abbr -a lll 'exa -la --icons --color=always -s type -F'
  abbr -a lt "exa -l --tree -L 2 --icons --color=always -s type -F"
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
end

abbr -a cp "cp -i"
abbr -a mv "mv -i"
abbr -a rm "rm -i"

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

if command -v lvim > /dev/null
  abbr -a vi "lvim"
else if command -v nvim >  /dev/null
  abbr -a vi "nvim"
else
  abbr -a vi "vim"
end

if command -v paru > /dev/null
  abbr -a yeet "paru -Rsc"
end

if command -v bat > /dev/null
  abbr -a cat "bat"
end

if command -v pnpm > /dev/null
  abbr -a npm "pnpm"
end

