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
  shellAliases = {
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };
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
      # Stuff
      # pkgs.asciinema
      pkgs.fish
      pkgs.zsh
      # CLI tools
      pkgs.bat
      pkgs.curl
      pkgs.eza
      pkgs.fastfetch
      pkgs.fd
      pkgs.fzf
      pkgs.gh
      pkgs.git-get
      pkgs.jq
      pkgs.onefetch
      pkgs.ripgrep
      # pkgs.tree
      pkgs.watch
      # Nix stuff
      pkgs.alejandra
      pkgs.nixd
      # TUI
      pkgs.lazygit
      pkgs.btop
      pkgs.repgrep
      pkgs.ijq
      # Languages
      pkgs.rustup
      pkgs.file
      # Formatters
    ]
    ++ (lib.optionals isDarwin [
      # pkgs.ollama
      # pkgs.llama-cpp
      pkgs.macmon
      # darwin packages
    ])
    ++ (lib.optionals (isLinux && !isWSL) [
      # non-darwin packages
      pkgs.zathura
      pkgs.greetd.tuigreet
    ]);

  #---------------------------------------------------------------------
  # dotfiles
  #---------------------------------------------------------------------
  home.file = {
    ".zshenv" = {
      source = ./.zshenv;
    };
  };

  xdg.configFile =
    {
      # Always include these
      ghostty = {
        source = ./ghostty;
        recursive = true;
      };
      nvim = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/nvim";
      };
      zsh = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/zsh";
      };
      fish = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/fish";
      };
      "lazygit/config.yml" = {source = ./lazygit.yml;};
    }
    // (
      # Darwin stuf
      if isDarwin
      then {
        yabai = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/yabai";
        };
      }
      else {}
    )
    // (
      # Linux stuf
      if isLinux
      then {
        niri = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/niri";
        };
      }
      else {}
    );

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  # Playing around with this
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    shellAliases = shellAliases;
  };

  # Using this alongside nushell for now.
  programs.oh-my-posh = {
    enable = true;
    enableNushellIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./omp.json);
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

  programs.gpg.enable = !isDarwin;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    config = {
      whitelist = {
        # Should add the following: polymath, stormwater-ai, uzaaft
      };
    };
  };

  programs.fuzzel.enable = isLinux;
}
