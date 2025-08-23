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
  if [[ ! -e ${zsh_plugins}/powerlevel10k ]]; then
    clone-plugin "https://github.com/romkatv/powerlevel10k"
    make -C ${zsh_plugins}/powerlevel10k pkg > /dev/null || echo "Error building powerlevel10k"
  fi
  if [[ ! -e ${zsh_plugins}/zsh-nvim-appname ]]; then
    clone-plugin "https://github.com/mehalter/zsh-nvim-appname"
    zcompile-many ${zsh_plugins}/zsh-nvim-appname/zsh-nvim-appname.plugin.zsh
  fi
  
  if [[ ! -e ${zsh_plugins}/yabai-zsh-completions ]]; then
    clone-plugin "https://github.com/Amar1729/yabai-zsh-completions"
    zcompile-many ${zsh_plugins}/yabai-zsh-completions/yabai-zsh-completions.plugin.zsh
  fi

  unfunction zcompile-many clone-plugin
}

# --- zsh plugin manager updater ---
function zsh_update_plugins() { rm -rf ${zsh_plugins}/**; zsh_install_missing_plugins }

# --- install zsh plugins ---
zsh_install_missing_plugins

# --- zsh-syntax-highlighting ---
source ${zsh_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# --- zsh-autosuggestions ---
source ${zsh_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh

bindkey '^ ' autosuggest-accept

