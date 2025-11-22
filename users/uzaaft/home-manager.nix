{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  sshKeyPath = (
    if isLinux
    then "~/.ssh/id_ed25519.pub"
    else "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  );
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "25.05";

  xdg.enable = true;

  # Packages I always want installed.
  home.packages =
    [
      pkgs.amp
      pkgs._1password-cli
      # Stuff
      # pkgs.asciinema
      # CLI tools
      pkgs.alejandra
      pkgs.attic-client
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
      pkgs.nix-output-monitor
      pkgs.nixd
      pkgs.nodejs-slim_24
      pkgs.onefetch
      pkgs.repgrep
      pkgs.ripgrep
      pkgs.tmux
      pkgs.tree
      pkgs.watch
    ]
    ++ (lib.optionals isDarwin [
      ])
    ++ (lib.optionals isLinux [
      # non-darwin packages
      pkgs.usbutils
      pkgs.ghostty
      pkgs.pciutils
      # Fallback CPU based terminal
      pkgs.foot
    ]);

  #---------------------------------------------------------------------
  # dotfiles
  #---------------------------------------------------------------------
  home.file = {
    ".zshenv" = {
      source = builtins.path {path = ./.zshenv;};
    };
    ".tmux.conf" = {
      source = builtins.path {path = ./.tmux.conf;};
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
    nh.enable = true;
    ghostty = {
      enable = isLinux;
    };

    gpg.enable = !isDarwin;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      silent = true;
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
          email = "git@uzaaft.me";
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
            IdentityAgent "${sshKeyPath}"
          ''
          else ""
        }
      '';
    };

    git = {
      lfs.enable = true;
      enable = true;

      ignores = [".DS_Store" ".direnv" ".env" ".rgignore"];

      settings = {
        user.name = "Uzair Aftab";
        user.email = "git@uzaaft.me";
        # Sign all commits using ssh key
        fetch = {
          prune = true;
        };
        aliases = {
          st = "status";
          feedback = "!f() { git checkout -b \"$(git rev-parse --abbrev-ref HEAD)/feedback\" && git add -A && git commit -m \"$1\"; }; f";
        };

        branch.autosetuprebase = "always";
        color.ui = true;
        github.user = "uzaaft";
        push.default = "tracking";
        init.defaultBranch = "main";
        commit.gpgsign = true;
        gpg.format = "ssh";
        signing = {
          format = "ssh";
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";
        };
        user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";

        "gpg \"ssh\"" =
          if isDarwin
          then {program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";}
          else {};
      };
    };
  };
}
