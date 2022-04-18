# Create a function in fish
function upgrade
  brew update
  brew upgrade neovim
  brew upgrade --cask wezterm-nightly --no-quarantine --greedy-latest
  brew upgrade
  rustup update
  pnpm update -g
end

