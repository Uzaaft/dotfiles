# Create a function in fish
function upgrade
  if command -v brew >/dev/null
     brew update
     brew upgrade neovim
     brew upgrade --cask wezterm-nightly --no-quarantine --greedy-latest
     brew upgrade
  else if command -v paru > /dev/null
    paru -Syyuu
  else
    sudo pacman -Syyuu
  end
  rustup update
  cargo install-update -a
end

