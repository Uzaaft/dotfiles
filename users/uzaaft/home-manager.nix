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
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };
  programs.git = {
    enable = true;
    userName = "Uzair Aftab";
    userEmail = "uzaaft@outlook.com";

    extraConfig = {
      fetch = {
        prune = true;
      };
      branch.autosetuprebase = "always";
      color.ui = true;
      github.user = "uzaaft";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  # Packages I always want installed.
  home.packages =
    [
      pkgs._1password-cli
      # Stuff
      pkgs.asciinema
      # CLI tools
      pkgs.bat
      pkgs.eza
      pkgs.fd
      pkgs.fzf
      pkgs.gh
      pkgs.htop
      pkgs.jq
      pkgs.ripgrep
      pkgs.tree
      pkgs.watch
      pkgs.hyperfine
      pkgs.git-get
      pkgs.gh-dash
      pkgs.dua
      pkgs.curl
      pkgs.fastfetch
      pkgs.onefetch
      pkgs.fish
      pkgs.dua
      pkgs.cargo-update
      # Nix stuff
      pkgs.alejandra
      pkgs.nixd
      # TUI
      pkgs.lazygit
      pkgs.zigpkgs."0.13.0"
    ]
    ++ (lib.optionals isDarwin [
      pkgs.ollama
      pkgs.llama-cpp
      pkgs.macmon
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
