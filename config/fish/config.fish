# Fish configuration - optimized for speed
# Only run expensive operations in interactive mode

# Fast startup - disable greeting
set -U fish_greeting

if status is-interactive
    # Vi mode with custom bindings
    fish_vi_key_bindings

    # Simple, fast prompt
    function fish_prompt
        set_color magenta --bold
        echo -n (pwd)
        set_color red
        echo -n ' $ '
        set_color normal
    end

    # Lazy load integrations
    if type -q fzf
        fzf --fish | source
    end

    if type -q direnv
        direnv hook fish | source
    end
end

# Universal variables (set once, persist across sessions)
# Run these once if not already set
    # Environment variables
set -gx NPM_CONFIG_PREFIX "/Users/uzaaft/.npm-global"
set -gx GIT_PATH "$HOME/repositories"
set -gx GEM_HOME "$HOME/.gem"
set -gx DENO_INSTALL "$HOME/.deno"
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx BAT_THEME "Catppuccin-mocha"
set -gx PNPM_HOME "$HOME/pnpm"
set -gx ANTHROPIC_API_KEY "op://Personal/AnthropicNeovim/credential"

# Path configuration (persistent)
switch (uname)
    case 'Darwin'
        fish_add_path /opt/homebrew/opt/rustup/bin
        fish_add_path /opt/homebrew/opt/llvm/bin
        fish_add_path /opt/homebrew/bin
        fish_add_path /opt/homebrew/opt/gnu-sed/libexec/gnubin
        fish_add_path /opt/homebrew/opt/libpq/bin
end

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/pnpm
fish_add_path $HOME/go/bin
fish_add_path $HOME/.npm-global/bin
fish_add_path $GEM_HOME/bin

# Dynamic MANPAGER based on nvim context
if set -q NVIM_LISTEN_ADDRESS; or set -q NVIM
    set -gx MANPAGER "nvr -c 'Man!' -o -"
else
    set -gx MANPAGER "nvim -c 'Man!'"
end
