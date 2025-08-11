{inputs, ...}: {
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

  neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default.overrideAttrs (old: {
    meta =
      old.meta
      or {}
      // {
        maintainers = old.maintainers or [];
      }; # TS Parsers are installed through Lazy.vim
    treesitter-parsers = {};
  });

  crush = pkgs.buildGoModule (finalAttrs: {
    pname = "crush";
    version = "0.4.0";

    src = pkgs.fetchFromGitHub {
      owner = "charmbracelet";
      repo = "crush";
      tag = "v${finalAttrs.version}";
      hash = "sha256-SjrkQFSjJrPNynARE92uKA53hkstIUBSvQbqcYSsnaM=";
    };
    doCheck = false;
    vendorHash = "sha256-aI3MSaQYUOLJxBxwCoVg13HpxK46q6ZITrw1osx5tiE=";

    meta = {
      description = "Glamourous AI coding agent for your favourite terminal";
      homepage = "https://github.com/charmbracelet/crush";
      changelog = "https://github.com/charmbracelet/crush/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.fsl11Mit;
      mainProgram = "crush";
    };
  });
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
      crush
      pkgs.llama-cpp
      pkgs.ollama
      pkgs.python313Packages.huggingface-hub
      pkgs.pciutils
      pkgs._1password-cli
      # Stuff
      # pkgs.asciinema
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
      pkgs.git-lfs
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
      pkgs.tmux
      # Languages
      pkgs.rustup
      pkgs.file
      # AI
      pkgs.codex
      pkgs.claude-code
      pkgs.gemini-cli

      # neomutt wizard
      pkgs.mutt-wizard
    ]
    ++ (lib.optionals isDarwin [
      ])
    ++ (lib.optionals isLinux [
      # non-darwin packages
      pkgs.zathura
      pkgs.greetd.tuigreet
    ]);

  #---------------------------------------------------------------------
  # dotfiles
  #---------------------------------------------------------------------
  home.file = {
    ".zshenv" = {
      source = builtins.path {path = ./.zshenv;};
    };
  };

  xdg.configFile =
    {
      # Always include these
      "ghostty/config".text = builtins.readFile ./ghostty/config;
      "ghostty/config-linux".text = builtins.readFile ./ghostty/config-linux;
      "ghostty/cursor.glsl".text = builtins.readFile ./ghostty/cursor.glsl;
      nvim = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/nvim";
      };
      zsh = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/zsh";
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
    package = neovim-unwrapped;
  };
  programs.neomutt = {
    enable = true;
    package = pkgs.neomutt;
  };

  programs.git = {
    lfs.enable = true;
    enable = true;
    userName = "Uzair Aftab";
    userEmail = "uzaaft@outlook.com";

    extraConfig = {
      # Sign all commits using ssh key
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

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Uzair Aftab";
        email = "uzaaft@outlook.com";
      };
    };
  };

  programs.fuzzel.enable = isLinux;
}
