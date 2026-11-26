{inputs, ...}: {
  config,
  currentSystemName,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  isMacRunner = currentSystemName == "macbook-m3-max";
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

    lg = "lazygit";
    ldo = "lazydocker";
    gg = "git get";
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gdiff = "git diff";
    gp = "git push";
    gs = "git status";
    gt = "git tag";
    ":q" = "exit";
    c = "cargo";
    pp = "pnpm";
    atc = "amp threads continue";
    ls-scripts = "cat package.json | jq .scripts";
  };

  sshKeyPath = (
    if isLinux
    then "~/.ssh/id_ed25519.pub"
    else "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  );

  dotfilesPath = "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles";
  mutableConfig = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";

  rexHosts = lib.optionals (currentSystemName == "macbook-m5") [
    {
      label = "macbook-m3-max-rex.tailed558.ts.net";
      endpoints = ["macbook-m3-max-rex.tailed558.ts.net"];
    }
    {
      label = "bobr";
      endpoints = ["https://uzaaft@bobr.tailed558.ts.net"];
    }
    {
      label = "eik-a100-vm";
      endpoints = ["https://eik-a100-vm.tailed558.ts.net"];
    }
    {
      label = "eik-rtx6000-vm";
      endpoints = ["https://eik-rtx6000-vm.tailed558.ts.net"];
    }
  ];
in {
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
    inputs.rex.homeManagerModules.default
  ];

  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "25.05";

  xdg.enable = true;

  # Home Manager loads these in every shell it manages.
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
    // lib.optionalAttrs (isDarwin && !isMacRunner) {
      SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
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
      pkgs.amp
      pkgs.snowstead
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
      pkgs.hunk
      pkgs.ijq
      pkgs.jj-get
      pkgs.jq
      pkgs.nix-output-monitor
      pkgs.nixd
      pkgs.vscode-json-languageserver # Json lsp
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
      pkgs._1password-cli
      # pkgs.llama-cpp
    ])
    ++ (lib.optionals (isLinux || isMacRunner) [
      pkgs.agy
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

  home.activation.rexConfigDirectory = lib.hm.dag.entryBetween ["linkGeneration"] ["writeBoundary"] ''
    if [ -L "${config.xdg.configHome}/rex" ] &&
       [ "$(readlink -f "${config.xdg.configHome}/rex")" = "${dotfilesPath}/users/uzaaft/rex" ]; then
      run unlink "${config.xdg.configHome}/rex"
    fi
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
      "rex/init.lua" = {
        source = mutableConfig "users/uzaaft/rex/init.lua";
      };
      "rex/layout.lua" = {
        source = mutableConfig "users/uzaaft/rex/layout.lua";
      };
      "rex/hosts.lua" = {
        text = lib.concatMapStringsSep "\n" (host: ''
          rex.host{
              label = ${builtins.toJSON host.label},
              endpoints = { ${lib.concatMapStringsSep ", " builtins.toJSON host.endpoints} },
          }
        '') rexHosts;
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
        "preview"
        "rex.zsh"
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

  # The system launchd daemon owns the runner server; the upstream Home
  # Manager module supplies the CLI, terminfo, and SSH terminal fallback.
  programs.rex.enable = isMacRunner;

  programs.ssh = lib.mkIf isMacRunner {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        IdentityAgent = "none";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
        ForwardAgent = false;
        Compression = true;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control-%r@%h:%p";
        ControlPersist = "1h";
      };
      "eik-a100-vm" = {
        HostName = "192.168.122.14";
        User = "u";
        ProxyJump = "uzair@100.91.232.92";
      };
      "eik-rtx6000-vm" = {
        HostName = "192.168.122.232";
        User = "u";
        ProxyJump = "uzair@100.96.97.103";
      };
    };
  };

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

  programs.direnv-instant.enable = true;

  programs.nushell = {
    enable = true;
    shellAliases = builtins.removeAttrs shellAliases ["ls-scripts"];
    # Import the Nix and Home Manager environment without running interactive
    # zsh plugins. NUL delimiters preserve spaces, '=' and multiline values.
    extraEnv = ''
      ${pkgs.coreutils}/bin/env -u __HM_SESS_VARS_SOURCED ${pkgs.zsh}/bin/zsh -l -c 'source ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh; ${pkgs.coreutils}/bin/env -0'
      | split row (char nul)
      | where {|entry| $entry != "" }
      | parse --regex '(?s)^(?<name>[^=]+)=(?<value>.*)$'
      | where name not-in [PWD SHLVL _ SHELL CMD_DURATION_MS LAST_EXIT_CODE]
      | transpose --header-row --as-record
      | update PATH {|vars| $vars.PATH | split row (char esep) | uniq }
      | load-env
      $env.SHELL = '${pkgs.nushell}/bin/nu'
      $env.DIRENV_INSTANT_SHELL = 'nu'
    '';
    extraConfig = ''
      # Source the script directly; `oh-my-posh init nu` only installs it
      # into an autoload directory that may not match this config directory.
      source ${pkgs.runCommand "oh-my-posh-init.nu" {nativeBuildInputs = [pkgs.nushell];} ''
        ${lib.getExe pkgs.oh-my-posh} init nu --print --config ${./omp.json} > "$out"
      ''}
      $env.config.show_banner = false
      $env.config.highlight_resolved_externals = true
      def ls-scripts [] { open package.json | get scripts }
      $env.config.keybindings ++= [{
        name: git_project
        modifier: control
        keycode: char_g
        mode: [emacs vi_insert vi_normal]
        event: {
          send: executehostcommand
          cmd: 'let selected = (^($env.HOME | path join ".local/bin/git-project") | str trim --right --char (char nl)); if ($selected | is-not-empty) { cd $selected }'
        }
      }]
    '' + lib.optionalString isDarwin ''
      def openwin [app: string] {
        ^osascript -e 'on run argv
          tell application (item 1 of argv) to activate
          tell application "System Events" to keystroke "n" using command down
        end run' $app
      }
    '';
  };

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

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    # zshrc.zsh runs its own deferred compinit.
    enableCompletion = false;
    # zshrc.zsh appends with inc_append_history instead of sharing.
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 1000000;
      save = 1000000;
      share = false;
      extended = true;
    };
    envExtra = ''source "$ZDOTDIR/zshenv.zsh"'';
    profileExtra = ''source "$ZDOTDIR/zprofile.zsh"'';
    initContent = ''source "$ZDOTDIR/zshrc.zsh"'';
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
          if isLinux || isMacRunner
          then "${config.home.homeDirectory}/.ssh/id_ed25519.pub"
          else "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";
      };
      user.signingkey =
        if isLinux || isMacRunner
        then "${config.home.homeDirectory}/.ssh/id_ed25519.pub"
        else "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps";
    };
  };
}
