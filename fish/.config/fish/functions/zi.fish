function zi
  builtin zi $argv
  if test -d .git
    onefetch
  end
end
