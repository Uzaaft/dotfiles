set -gx NPM_CONFIG_PREFIX ~/.npm-global
set -gx PATH ~/.cargo/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/.npm-global/bin/ $PATH
set -gx ANDROID_HOME ~/Library/Android/Sdk
set -gx PATH $ANDROID_HOME/emulator $PATH
set -gx PATH $ANDROID_HOME/tools $PATH
set -gx PATH $ANDROID_HOME/tools/bin $PATH
set -gx PATH $ANDROID_HOME/platform-tools $PATH
set -gx DYLD_LIBRARY_PATH ~/Qt/5.14.0/clang_64/lib $DYLD_LIBRARY_PATH
set -gx PATH ~/Qt/5.12.12/clang_64/bin/ $PATH
set -gx XDG_CONFIG_HOME ~/.config
set -gx GITSTATUS_LOG_LEVEL INFO
set -gx TMUX_CONFIG_DIR ~/.config/tmux
# set -gx TERM "wezterm"
set -gx SCCACHE_SIZE 50G
set -gx PATH ~/go/bin $PATH
