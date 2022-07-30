function cd
  builtin cd $argv
    if test -d .git
      onefetch
    end
end
