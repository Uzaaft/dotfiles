{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  onePassPath = (
    if isLinux
    then "~/.1password/agent.sock"
    # TODO: Symlink this to a more conviniet location
    else "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  );

  crush = import ./crush.nix {
    inherit lib pkgs;
  };
  tsgo = import ./typescript-go.nix {
    inherit lib pkgs;
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
      inputs.nix-ai-tools.packages.${pkgs.system}.amp
      pkgs._1password-cli
      pkgs.llama-cpp
      pkgs.ollama
      pkgs.pciutils
      # Stuff
      # pkgs.asciinema
      # CLI tools
      pkgs.alejandra
      pkgs.ast-grep
      pkgs.bat
      pkgs.btop
      pkgs.curl
      pkgs.eza
      pkgs.fastfetch
      pkgs.fd
      pkgs.file
      pkgs.fzf
      pkgs.gh
      pkgs.git-get
      pkgs.git-lfs
      pkgs.ijq
      pkgs.jq
      pkgs.lazygit
      pkgs.nixd
      pkgs.nodejs_24
      pkgs.onefetch
      pkgs.repgrep
      pkgs.ripgrep
      pkgs.tmux
      pkgs.tree
      pkgs.watch
      # AI
    ]
    ++ (lib.optionals isDarwin [
      ])
    ++ (lib.optionals isLinux [
      # non-darwin packages
      pkgs.greetd.tuigreet
      pkgs.usbutils
      pkgs.ghostty
      tsgo
      crush
    ]);

  #---------------------------------------------------------------------
  # dotfiles
  #---------------------------------------------------------------------
  home.file = {
    ".zshenv" = {
      source = builtins.path {path = ./.zshenv;};
    };
    ".claude/CLAUDE.md" = {
      source = builtins.path {path = ./claude.md;};
    };
  };

  xdg.configFile =
    {
      # Always include these
      "ghostty/config".text = builtins.readFile ./ghostty/config;
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
    claude-code = {
      enable = true;
      agents = {
        api-designer = builtins.readFile ./agents/api-designer.md;
        backend-developer = builtins.readFile ./agents/backend-developer.md;
        nextjs-developer = builtins.readFile ./agents/nextjs-developer.md;
        perf-engineer = builtins.readFile ./agents/perf-engineer.md;
        react-specialist = builtins.readFile ./agents/react-specialist.md;
        senior-code-reviewer = builtins.readFile ./agents/senior-code-reviewer.md;
        rust-engineer = builtins.readFile ./agents/rust-engineer.md;
        terraform-engineer = builtins.readFile ./agents/terraform-engineer.md;
        ui-engineer = builtins.readFile ./agents/ui-engineer.md;
      };
    };
    gpg.enable = !isDarwin;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      config = {
        whitelist = {
          # Should add the following: polymath, stormwater-ai, uzaaft
          prefix = [
            "$HOME/repositories/github.com/uzaaft"
            "$HOME/repositories/github.com/polymath-as"
          ];
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
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

      plugins = [
        pkgs.vimPlugins.nvim-treesitter
      ];
    };

    ssh = {
      enable = true;
      extraConfig = ''
        ${
          if isDarwin
          then ''
            IdentityAgent "${onePassPath}"
          ''
          else ""
        }
      '';
    };

    git = {
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
        user = {
          user = "Uzair Aftab";
          email = "uzaaft@outlook.com";
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";
        };
        gpg = {
          format = "ssh";
        };

        "gpg \"ssh\"" =
          if isLinux
          then {}
          else {program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";};
        commit = {
          gpgsign = true;
        };
      };
    };
  };
}
