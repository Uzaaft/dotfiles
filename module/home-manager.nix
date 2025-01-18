{inputs}: {
  pkgs,
  config,
  ...
}: let
in {
  # https://mipmip.github.io/home-manager-option-search/

  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    fd
    gnused
    ripgrep
    wget
    gh
    nixd
    alejandra
    neovim
    lazygit
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.file = {
    ".zshenv" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/.zshenv";
    };
  };

  xdg.configFile = {
    ghostty = {
      source = config.lib.file.mkOutOfStoreSymlink ../config/ghostty;
      recursive = true;
    };
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/nvim";
    };
    zsh = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/zsh";
    };
    yabai = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/yabai";
    };
  };
}
