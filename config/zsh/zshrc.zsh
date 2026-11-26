# Based on https://gist.github.com/mehalter/2809925b6e266b3574c7deab3dae711a
# Home Manager sources this from $ZDOTDIR/.zshrc after setting history vars.

# --- powerlevel10k instant prompt; must stay near the top ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- zsh data directories ---
zsh_data="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zsh_plugins="${zsh_data}/plugins"
mkdir -p -- $zsh_data $zsh_cache $zsh_plugins

# --- minimal zsh plugin manager ---
function zsh_install_missing_plugins() {
  function zcompile-many() { local f; for f; do zcompile -R -- "$f".zwc "$f"; done }
  function clone-plugin() {
    local plugin="$(basename ${1})"
    echo "Installing ${plugin}"
    git clone --quiet --depth=1 "${1}.git" ${zsh_plugins}/${plugin} > /dev/null
  }
  # clone plugins, add more plugin downloads here with optional compilation calls to improve startup
  if [[ ! -e ${zsh_plugins}/zsh-completions ]]; then
    clone-plugin "https://github.com/zsh-users/zsh-completions"
  fi
  if [[ ! -e ${zsh_plugins}/fzf-tab ]]; then
    clone-plugin "https://github.com/Aloxaf/fzf-tab"
    zcompile-many ${zsh_plugins}/fzf-tab/*.zsh
  fi
  if [[ ! -e ${zsh_plugins}/zsh-syntax-highlighting ]]; then
    clone-plugin "https://github.com/zsh-users/zsh-syntax-highlighting"
    zcompile-many ${zsh_plugins}/zsh-syntax-highlighting/{zsh-syntax-highlighting.zsh,highlighters/*/*.zsh}
  fi
  if [[ ! -e ${zsh_plugins}/zsh-autosuggestions ]]; then
    clone-plugin "https://github.com/zsh-users/zsh-autosuggestions"
    zcompile-many ${zsh_plugins}/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
  fi
  if [[ ! -e ${zsh_plugins}/zsh-nvim-appname ]]; then
    clone-plugin "https://github.com/mehalter/zsh-nvim-appname"
    zcompile-many ${zsh_plugins}/zsh-nvim-appname/zsh-nvim-appname.plugin.zsh
  fi
  unfunction zcompile-many clone-plugin
}
# --- zsh plugin manager updater ---
function zsh_update_plugins() { rm -rf ${zsh_plugins}/**; zsh_install_missing_plugins }

# --- install zsh plugins ---
zsh_install_missing_plugins

# --- configure zsh options ---
setopt autocd
setopt bash_rematch
setopt correct
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history
setopt interactivecomments
HISTORY_IGNORE='(ls|[bf]g|exit|reset|clear|cd|cd ..)'
export KEYTIMEOUT=10
[[ -f $HISTFILE ]] && chmod 600 -- $HISTFILE

# --- configure path; only directories that exist on this machine ---
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.bun/bin
  $HOME/pnpm
  $HOME/go/bin
  $HOME/.npm-global/bin
  /opt/homebrew/opt/rustup/bin
  /opt/homebrew/opt/llvm/bin
  /opt/homebrew/bin
  /opt/homebrew/opt/gnu-sed/libexec/gnubin
  /opt/homebrew/opt/libpq/bin
  $path
)
path=(${^path}(N-/))
fpath=(
  /opt/homebrew/share/zsh/site-functions(N-/)
  $zsh_plugins/zsh-completions/src
  $zsh_plugins/zsh-nvim-appname
  $fpath
)

# --- fzf ---
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# --- completion ---
autoload -Uz compinit
zmodload zsh/complist
_comp_options+=(globdots) # include hidden files
comp_cache=${zsh_cache}/zcompdump-${ZSH_VERSION}
fresh_comp_cache=(${comp_cache}(N.mh-24))
if (( $#fresh_comp_cache )); then
  compinit -C -d ${comp_cache} # dump is fresh, skip the security check
else
  compinit -d ${comp_cache}
fi
unset fresh_comp_cache
[[ ${comp_cache}.zwc -nt ${comp_cache} ]] || zcompile -R -- "${comp_cache}".zwc "${comp_cache}" # compile completion cache
zstyle ':completion:*' cache-path ${zsh_cache} # cache path
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # use ls colors
zstyle ':completion:*' completer _complete # approximate completion matches
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*' # case insensitive, partial word, substring
zstyle ':completion::complete:*' use-cache 1 # use cache
zstyle ':completion:*:git-checkout:*' sort false # don't sort git checkout
zstyle ':completion:*:descriptions' format '[%d]' # enable group supported descriptions
source <(COMPLETE=zsh jj)

# --- keybindings ---
autoload -Uz edit-command-line
function zle-keymap-select() { zle reset-prompt; zle -R }
zle -N edit-command-line
zle -N zle-keymap-select
bindkey -v
if [[ $TERM == tmux* ]]; then
  bindkey '^[[1~' beginning-of-line
  bindkey '^[[4~' end-of-line
else
  bindkey '^[[H' beginning-of-line
  bindkey '^[[F' end-of-line
fi
bindkey '^[[3~' delete-char
bindkey -M viins '^a' vi-beginning-of-line
bindkey -M viins '^e' vi-end-of-line
bindkey -M viins '^k' kill-line
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward
bindkey "^?" backward-delete-char
bindkey '^x^e' edit-command-line
bindkey '^ ' autosuggest-accept # widget comes from zsh-autosuggestions below

# expand ... to ../.. recursively
function _rationalise-dot { # This was written entirely by Mikael Magnusson (Mikachu)
  local MATCH # keep the regex match from leaking to the environment
  if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert
  else
    zle self-insert
  fi
}
zle -N _rationalise-dot
bindkey . _rationalise-dot
bindkey -M isearch . self-insert # without this, typing . aborts incr history search

# Ctrl+G: cd into a project picked by git-project
function _git_go() {
  local selected_path="$("$HOME/.local/bin/git-project")"
  [[ -n $selected_path ]] && cd -- "$selected_path"
  zle reset-prompt
}
zle -N _git_go
bindkey '^G' _git_go

# === PLUGINS ===

# --- fzf-tab ---
source ${zsh_plugins}/fzf-tab/fzf-tab.plugin.zsh
zstyle ':fzf-tab:*' switch-group ',' '.' # switch groups with ,/.
zstyle ':fzf-tab:complete:*:options' fzf-preview  # disable options preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview # disable subcommand preview
zstyle ':fzf-tab:complete:(nvapp|pg|pd|pe|td|te):*' fzf-preview # disable preview for my own zsh completion
zstyle ':fzf-tab:complete:-command-:*' fzf-preview '(out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "${(P)word}"'
zstyle ':fzf-tab:complete:*:*' fzf-preview '$ZDOTDIR/preview ${(Q)realpath}'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $word'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
  "modified file") git diff --color=always $word ;;
  "recent commit object name") git show --color=always $word ;;
  *) git log --color=always $word ;;
  esac'

# --- zsh-nvim-appname ---
source ${zsh_plugins}/zsh-nvim-appname/zsh-nvim-appname.plugin.zsh

# --- zsh-syntax-highlighting; after all other widgets are defined ---
source ${zsh_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- zsh-autosuggestions ---
source ${zsh_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- powerlevel10k prompt ---
# nixpkgs revisions disagree on where the theme lands, so glob both layouts
_p10k_themes=(
  /etc/profiles/per-user/${USER:-$USERNAME}/share/zsh{/themes/powerlevel10k,-powerlevel10k}/powerlevel10k.zsh-theme(N)
  $HOME/.nix-profile/share/zsh{/themes/powerlevel10k,-powerlevel10k}/powerlevel10k.zsh-theme(N)
)
(( $#_p10k_themes )) && source $_p10k_themes[1]
unset _p10k_themes
[[ -r $ZDOTDIR/.p10k.zsh ]] && source $ZDOTDIR/.p10k.zsh

# === END PLUGINS ===

# --- source various other scripts ---
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/rex.zsh
