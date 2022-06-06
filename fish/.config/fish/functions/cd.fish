function cd
  builtin cd $argv
    if test -d .git
      onefetch
      git fetch > /dev/null
    end
end
