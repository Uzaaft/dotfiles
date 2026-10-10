{inputs, ...}: {
  config,
  currentSystemName,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  isGraphicalLinux = currentSystemName == "vm-aarch64" || currentSystemName == "ws-nvda-x86_64";

  shellAliases = {
    cat = "bat";
    vi = "nvim";
    vim = "nvim";
    # eza aliases
    l = "eza -a --icons --color=always -s type -F ";
    ll = "eza -l --icons --color=always -s type -F";
    lll = "eza -la --icons --color=always -s type -F";
    ls = "eza -a --icons --color=always -s type -F";
    lt = "eza -T --icons=auto --group-directories-first --hyperlink";

    gg = "git get";
    c = "cargo";
    pp = "pnpm";
    ls-scripts = "cat package.json | jq .scripts";
  };

  sshKeyPath = (
    if isLinux
    then "~/.ssh/id_ed25519.pub"
    else "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  );

  dotfilesPath = "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles";
  mutableConfig = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
in {
  imports = [inputs.direnv-instant.homeModules.direnv-instant];

  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "25.05";
  home.sessionVariables.OPENCODE_DISABLE_AUTOUPDATE = "true";

  xdg.enable = true;

  # Packages I always want installed.
  home.packages =
    [
      pkgs.amp
      pkgs.neovim
      # Stuff
      # CLI tools
      pkgs.bat
      pkgs.btop
      pkgs.curl
      pkgs.eza
      pkgs.fd
      pkgs.file
      pkgs.fzf
      pkgs.gh
      pkgs.jj-get
      pkgs.ijq
      pkgs.jq
      pkgs.vscode-json-languageserver # Json lsp
      pkgs.nix-output-monitor
      pkgs.nixd
      pkgs.ripgrep
      pkgs.tmux
      pkgs.tree
      pkgs.watch
      pkgs.zsh-powerlevel10k
    ]
    ++ (lib.optionals isDarwin [
      ])
    ++ (lib.optionals isLinux [
      # non-darwin packages
      pkgs.usbutils
      pkgs.pciutils
      # pkgs.llama-cpp
      pkgs.claude-code
      pkgs.codex
      pkgs.opencode
    ])
    ++ (lib.optionals isGraphicalLinux [
      # Fallback CPU based terminal
      pkgs.foot
    ]);

  #---------------------------------------------------------------------
  # dotfiles
  #---------------------------------------------------------------------
  home.file = {
    ".zshenv" = {
      source = mutableConfig "users/uzaaft/.zshenv";
    };
    ".tmux.conf" = {
      source = mutableConfig "users/uzaaft/.tmux.conf";
    };
    ".local/bin/git-project" = {
      source = mutableConfig "stowed/.local/bin/git-project";
    };
    ".cargo/config.toml" = {
      source = mutableConfig "stowed/.cargo/config.toml";
    };
    ".claude/settings.json" = {
      source = mutableConfig "users/uzaaft/claude/settings.json";
    };
    ".codex/AGENTS.md" = {
      source = mutableConfig "users/uzaaft/agents.md";
    };
    "opencode/opencode.json" = {
      source = mutableConfig "users/uzaaft/opencode.json";
    };
    ".agents/skills".source = mutableConfig "users/uzaaft/agent-skills";
    ".claude/skills".source = mutableConfig "users/uzaaft/agent-skills";
  };

  xdg.configFile =
    {
      # Always include these
      "bash/bashrc" = {
        source = mutableConfig "users/uzaaft/bashrc";
      };
      ghostty = {
        source = mutableConfig "users/uzaaft/ghostty";
      };
      amp = {
        source = mutableConfig "users/uzaaft/amp";
      };
      rex = {
        source = mutableConfig "users/uzaaft/rex";
      };

      nvim = {
        source = mutableConfig "config/nvim";
      };
      "nushell/config.nu" = {
        source = mutableConfig "users/uzaaft/config.nu";
      };
      opencode = {
        source = mutableConfig "users/uzaaft/opencode";
      };
      "jj/config.toml" = {
        source = mutableConfig "users/uzaaft/jujutsu.toml";
      };
      zsh = {
        source = mutableConfig "config/zsh";
      };
    }
    // (
      # Darwin stuf
      if isDarwin
      then {}
      else {}
    )
    // (
      # Linux stuf
      if isGraphicalLinux
      then {
        niri = {
          source = mutableConfig "config/niri";
        };
      }
      else {}
    );

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.ghostty = {
    enable = isGraphicalLinux;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    nix-direnv.enable = true;

    silent = true;
    config = {
      whitelist = {
        prefix = [
          "$HOME/repositories/github.com/uzaaft"
          "$HOME/repositories/github.com/polymath-as"
        ];
      };
    };
  };

  # This module replaces direnv's shell hooks with its asynchronous hooks.
  programs.direnv-instant.enable = true;

  programs.jujutsu = {
    enable = true;
  };

  programs.fuzzel.enable = isGraphicalLinux;

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = ["ignoredups" "ignorespace"];
    initExtra = ''
      if [ -r "$HOME/.config/bash/bashrc" ]; then
        . "$HOME/.config/bash/bashrc"
      fi
    '';
    shellAliases = shellAliases;
  };

  programs.git = {
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
      };

      branch.autosetuprebase = "always";
      merge.conflictstyle = "zdiff3";
      color.ui = true;
      github.user = "uzaaft";
      push.default = "tracking";
      init.defaultBranch = "master";
      commit.gpgsign = true;
      gpg.format = "ssh";
      signing = {
        format = "ssh";
        key =
          if isLinux
          then "${config.home.homeDirectory}/.ssh/id_ed25519.pub"
          else "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";
      };
      user.signingkey =
        if isLinux
        then "${config.home.homeDirectory}/.ssh/id_ed25519.pub"
        else "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";
    };
  };
}
