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
  onePassPath = "~/.1password/agent.sock";

  neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default.overrideAttrs (old: {
    meta =
      old.meta
      or {}
      // {
        maintainers = old.maintainers or [];
      }; # TS Parsers are installed through Lazy.vim
    treesitter-parsers = {};
  });

  crush = import ./crush.nix {
    inherit lib pkgs;
  };
  # tsgo = import ./typescript-go.nix {
  #   inherit lib pkgs;
  # };
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
      pkgs.tree
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
      pkgs.lmstudio
      pkgs.usbutils
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
  programs = {
    # TODO: add this whenever claude-code is released in hm
    # claude-code = {
    #   enable = true;
    #   agents = {
    #     api-designer = builtins.readFile ./agents/api-designer.md;
    #     backend-developer = builtins.readFile ./agents/backend-developer.md;
    #     nextjs-developer = builtins.readFile ./agents/nextjs-developer.md;
    #     perf-engineer = builtins.readFile ./agents/perf-engineer.md;
    #     react-specialist = builtins.readFile ./agents/react-specialist.md;
    #     senior-code-reviewer = builtins.readFile ./agents/senior-code-reviewer.md;
    #     rust-engineer = builtins.readFile ./agents/rust-engineer.md;
    #     terraform-engineer = builtins.readFile ./agents/terraform-engineer.md;
    #     ui-engineer = builtins.readFile ./agents/ui-engineer.md;
    #   };
    # };
    gpg.enable = !isDarwin;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      config = {
        whitelist = {
          # Should add the following: polymath, stormwater-ai, uzaaft
        };
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Uzair Aftab";
          email = "uzaaft@outlook.com";
        };
      };
    };

    fuzzel.enable = isLinux;

    neovim = {
      enable = true;
      package = neovim-unwrapped;
    };

    ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${onePassPath}
      '';
    };
  };

  programs.git = {
    lfs.enable = true;
    enable = true;

    userName = "Uzair Aftab";
    userEmail = "uzaaft@outlook.com";

    extraConfig =
      {
        # Sign all commits using ssh key
        fetch = {
          prune = true;
        };
        branch.autosetuprebase = "always";
        color.ui = true;
        github.user = "uzaaft";
        push.default = "tracking";
        init.defaultBranch = "main";
        user = {
          user = "Uzair Aftab";
          email = "uzaaft@outlook.com";
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";
        };
      }
      // (
        if !isLinux
        then {
          gpg = {
            format = "ssh";
          };
          "gpg \"ssh\"" = {
            program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          };
          commit = {
            gpgsign = true;
          };
        }
        else {}
      );
  };
}
