abbr -a yr 'cal -y'
abbr -a c cargo
abbr -a e lvim
abbr -a pr 'gh pr create -t (git show -s --format=%s HEAD) -b (git show -s --format=%B HEAD | tail -n+3)'

source ~/.config/fish/prompt.fish

if command -v pazi >/dev/null
  status --is-interactive; and pazi init fish | source
end
