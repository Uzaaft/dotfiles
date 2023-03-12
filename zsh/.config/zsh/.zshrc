source $ZDOTDIR/env.zsh
source $ZDOTDIR/alias.zsh



source $ZDOTDIR/prompt.zsh
compinit

eval "$(zoxide init zsh)"
# eval $(thefuck --alias --enable-experimental-instant-mode)
eval "$($(which rtx) activate zsh)"
# eval "$(pyenv init -)"

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

# bun completions
[ -s "/Users/uzaaft/.bun/_bun" ] && source "/Users/uzaaft/.bun/_bun"

source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh

