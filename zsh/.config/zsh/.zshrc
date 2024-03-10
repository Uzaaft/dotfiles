# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

fpath=($ZDOTDIR/completions $fpath)

source "$ZDOTDIR"/env.zsh
source "$ZDOTDIR"/prompt.zsh
source "$ZDOTDIR"/hooks.zsh
source "$ZDOTDIR"/brew.zsh

if command -v zoxide &> /dev/null; then eval "$(zoxide init zsh)"; fi
# eval $(thefuck --alias --enable-experimental-instant-mode)
eval "$($(which mise) activate zsh)"
# eval "$(pyenv init -)"

# export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

# bun completions
[ -s "/Users/uzaaft/.bun/_bun" ] && source "/Users/uzaaft/.bun/_bun"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/uzaaft/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/uzaaft/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/uzaaft/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/uzaaft/google-cloud-sdk/completion.zsh.inc'; fi

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
export PATH=$PATH:/Users/uzaaft/.spicetify
