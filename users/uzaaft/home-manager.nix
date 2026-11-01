{inputs, ...}: {
  config,
  currentSystemName,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  isGraphicalLinux = currentSystemName == "vm-aarch64";

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

  xdg.enable = true;

  # Home Manager loads these in every shell it manages, and nu inherits them
  # from the fish login shell.
  home.sessionVariables =
    {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
      GIT_PATH = "$HOME/repositories/";
      GEM_HOME = "$HOME/.gem";
      DENO_INSTALL = "$HOME/.deno/";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      PNPM_HOME = "$HOME/pnpm";
      BAT_THEME = "Catppuccin-mocha";
    }
    // lib.optionalAttrs isDarwin {
      SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      GOKU_EDN_CONFIG_FILE = "$HOME/.config/goku/karabiner.edn";
    };

  home.sessionPath =
    [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/.bun/bin"
      "$HOME/pnpm"
      "$HOME/go/bin"
      "$HOME/.npm-global/bin"
      "$HOME/.gem/bin"
    ]
    ++ lib.optionals isDarwin [
      "/opt/homebrew/opt/rustup/bin"
      "/opt/homebrew/opt/llvm/bin"
      "/opt/homebrew/bin"
      "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
      "/opt/homebrew/opt/libpq/bin"
    ];

  # Packages I always want installed.
  home.packages =
    [
      pkgs._1password-cli
      pkgs.amp
      pkgs.neovim
      # Stuff
      # CLI tools
      pkgs.bat
      pkgs.btop
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
    ])
    ++ (lib.optionals isGraphicalLinux [
      # Fallback CPU based terminal
      pkgs.foot
    ]);

  #---------------------------------------------------------------------
  # dotfiles
  #---------------------------------------------------------------------
  home.file = {
    ".local/bin/git-project" = {
      source = mutableConfig "stowed/.local/bin/git-project";
    };
    ".cargo/config.toml" = {
      source = mutableConfig "stowed/.cargo/config.toml";
    };
    ".codex/AGENTS.md" = {
      source = mutableConfig "users/uzaaft/agents.md";
    };
    ".agents/skills".source = mutableConfig "users/uzaaft/agent-skills";
    ".claude/skills".source = mutableConfig "users/uzaaft/agent-skills";
  };

  # Claude Code saves its settings by writing a temporary file beside the
  # file its link points at, then renaming it over. Through home-manager's
  # link that is the read-only store, so the link goes straight to the
  # dotfiles instead, and saves (such as installing a plugin) land there.
  home.activation.claudeSettings = lib.hm.dag.entryAfter ["linkGeneration"] ''
    run mkdir -p "$HOME/.claude"
    run ln -sfn "${dotfilesPath}/users/uzaaft/claude/settings.json" "$HOME/.claude/settings.json"
  '';

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
      "jj/config.toml" = {
        source = mutableConfig "users/uzaaft/jujutsu.toml";
      };
    }
    # Home Manager owns .zshenv, .zprofile and .zshrc in ZDOTDIR; they
    # source these files from the dotfiles.
    // builtins.listToAttrs (map (file: {
        name = "zsh/${file}";
        value.source = mutableConfig "config/zsh/${file}";
      }) [
        ".p10k.zsh"
        "aliases.zsh"
        "git_go.zsh"
        "path.zsh"
        "plugin_manager.zsh"
        "rationalise-dot.zsh"
        "zprofile.zsh"
        "zshenv.zsh"
        "zshrc.zsh"
      ])
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

  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
    interactiveShellInit = ''
      # Rex terminals run nu. Only the login shell Rex starts switches, so
      # running fish from nu stays in fish.
      if test "$TERM_PROGRAM" = rex; and status is-login
          exec nu
      end
    '';
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    # zshrc.zsh runs its own deferred compinit.
    enableCompletion = false;
    # zshrc.zsh appends with inc_append_history instead of sharing.
    history.share = false;
    envExtra = ''source "$ZDOTDIR/zshenv.zsh"'';
    profileExtra = ''source "$ZDOTDIR/zprofile.zsh"'';
    initContent = ''source "$ZDOTDIR/zshrc.zsh"'';
  };

  programs.nushell = {
    enable = true;
    extraConfig = ''source "${dotfilesPath}/users/uzaaft/config.nu"'';
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
