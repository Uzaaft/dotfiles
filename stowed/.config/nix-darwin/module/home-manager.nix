{inputs}: {
  pkgs,
  config,
  ...
}: let
  mono-lisa-font = inputs.self.packages.${pkgs.system}.mono-lisa;
  catppuccin-tmux = inputs.self.packages.${pkgs.system}.catppuccin-tmux;
in {
  # https://mipmip.github.io/home-manager-option-search/

  home.stateVersion = "24.05";

  fonts.fontconfig.enable = true;

  # home.packages = with pkgs; [
  #   aerospace
  #   doggo
  #   fd
  #   gh
  #   gnused
  #   graphite-cli
  #   mono-lisa-font
  #   ripgrep
  #   tree
  #   wget
  # ];

  programs.gpg.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    # enableFishIntegration gets enabled by default when enabling programs.fish
    # enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  # xdg.configFile = {
  #   aerospace = {
  #     source = config.lib.file.mkOutOfStoreSymlink ../config/aerospace;
  #     recursive = true;
  #   };
  #   dune = {
  #     source = config.lib.file.mkOutOfStoreSymlink ../config/dune;
  #     recursive = true;
  #   };
  #   ghostty = {
  #     source = config.lib.file.mkOutOfStoreSymlink ../config/ghostty;
  #     recursive = true;
  #   };
  #   nvim = {
  #     source = config.lib.file.mkOutOfStoreSymlink ../config/nvim;
  #     recursive = true;
  #   };
  # };
}
