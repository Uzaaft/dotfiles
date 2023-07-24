fpath=($ZDOTDIR/completions $fpath)

source "$ZDOTDIR"/env.zsh
source "$ZDOTDIR"/alias.zsh



source "$ZDOTDIR"/prompt.zsh

if command -v zoxide &> /dev/null; then eval "$(zoxide init zsh)"; fi
# eval $(thefuck --alias --enable-experimental-instant-mode)
eval "$($(which rtx) activate zsh)"
# eval "$(pyenv init -)"

# export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

# bun completions
[ -s "/Users/uzaaft/.bun/_bun" ] && source "/Users/uzaaft/.bun/_bun"

source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh
source $ZDOTDIR/alias.zsh


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/uzaaft/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/uzaaft/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/uzaaft/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/uzaaft/google-cloud-sdk/completion.zsh.inc'; fi
