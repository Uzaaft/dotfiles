ZDOTDIR=/home/uzaaft/.config/zsh
# Shell spesific variables
HISTFILE="$XDG_DATA_HOME"/.config/zsh/history
HISTSIZE=1000000
SAVEHIST=1000000
#Manpage stuff
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# rust paths 
export PATH=$PATH:/home/uzaaft/.cargo/bin
export PATH=$PATH:/home/uzaaft/.local/bin

# Node version manager
eval "$(fnm env)"

# Zoxide
eval "$(zoxide init zsh)"


export LSCOLORS=cxgxfxexbxegedabagacad
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/Applications/MATLAB_R2020b.app/bin:$PATH"
# Path to your oh-my-zsh installation.
export PATH="/home/uzaaft/.local/bin:$PATH"

fpath=($fpath ~/.config/zsh/autoload)
# export EDITOR='lvim'
export NPM_CONFIG_PREFIX=~/.npm-global
