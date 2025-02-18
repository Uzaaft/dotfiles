{
  isWSL,
  inputs,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "25.05";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed.
  home.packages =
    [
      pkgs._1password-cli
      pkgs.asciinema
      pkgs.bat
      pkgs.eza
      pkgs.fd
      pkgs.fzf
      pkgs.gh
      pkgs.htop
      pkgs.jq
      pkgs.ripgrep
      pkgs.sentry-cli
      pkgs.tree
      pkgs.watch
      pkgs.alejandra
      pkgs.nixd
      pkgs.lazygit
      pkgs.git-get
      pkgs.fzf
      pkgs.gh-dash
      pkgs.zigpkgs."0.13.0"
    ]
    ++ (lib.optionals isDarwin [
      pkgs.ollama
      pkgs.llama-cpp
      # darwin packages
    ])
    ++ (lib.optionals (isLinux && !isWSL) [
      # non-darwin packages
    ]);

  #---------------------------------------------------------------------
  # dotfiles
  #---------------------------------------------------------------------
  home.file = {
    ".zshenv" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/.zshenv";
    };
  };

  xdg.configFile =
    {
      # Always include these
      ghostty = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/ghostty";
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
    }
    // (
      if isDarwin
      then {
        # Darwin stuf
      }
      else {
      }
    )
    // (
      if isLinux
      then {
        # Linux stuf
      }
      else {}
    );

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = !isDarwin;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      whitelist = {
        # Should add the following: polymath, stormwater-ai, uzaaft
      };
    };
  };

  programs.jujutsu = {
    enable = true;
  };
}
