{inputs}: {
  pkgs,
  config,
  ...
}: let
in {
  # https://mipmip.github.io/home-manager-option-search/

  home.stateVersion = "24.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fd
    gnused
    ripgrep
    wget
    gh
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  xdg.configFile = {
    ghostty = {
      source = config.lib.file.mkOutOfStoreSymlink ../config/ghostty;
      recursive = true;
    };
  };

  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink ../config/nvim;
      recursive = true;
    };
  };

  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  #   extraLuaConfig = ''
  #     require('user')
  #   '';
  #   extraPackages = [
  #     # Included for nil_ls
  #     pkgs.cargo
  #     # Included to build telescope-fzf-native.nvim
  #     pkgs.cmake
  #     # Included for LuaSnip
  #     # pkgs.luajitPackages.jsregexp
  #   ];
  #   withNodeJs = true;
  #   withPython3 = true;
  #   withRuby = true;
  #   vimdiffAlias = true;
  #   viAlias = true;
  #   vimAlias = true;
  # };
}
