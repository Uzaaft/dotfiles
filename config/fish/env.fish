set -U GIT_PATH $HOME/repositories/
set -U FZF_DEFAULT_COMMAND "fd --type f --hidden --follow"
set -U FZF_DEFAULT_OPTS "--extended"
set -U FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
