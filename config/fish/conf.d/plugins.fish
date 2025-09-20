# Fish native features configuration (no plugins needed!)

# Autosuggestions (built-in)
set -g fish_autosuggestion_enabled 1

# Syntax highlighting colors (built-in)
set -g fish_color_command green
set -g fish_color_error red --bold
set -g fish_color_param cyan
set -g fish_color_comment brblack
set -g fish_color_operator magenta
set -g fish_color_escape yellow
set -g fish_color_autosuggestion brblack

# Pager colors for completions
set -g fish_pager_color_completion normal
set -g fish_pager_color_description yellow
set -g fish_pager_color_prefix cyan --bold --underline
set -g fish_pager_color_progress brwhite --background=cyan

# Enable fuzzy matching for tab completions (built-in)
set -g fish_complete_fuzzy_match 1