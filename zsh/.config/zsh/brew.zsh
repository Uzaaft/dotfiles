 if type brew &>/dev/null; then
     FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

     autoload -Uz compinit
     compinit

     autoload -Uz compinit
comp_cache=${zsh_cache}/zcompdump-${ZSH_VERSION}
compinit -d ${comp_cache}

fi
