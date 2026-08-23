{inputs, ...}: {
  config,
  currentSystemName,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  isVmAarch64 = currentSystemName == "vm-aarch64";
  isGraphicalLinux = isVmAarch64;

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
    c = "cargo";
    pp = "pnpm";
    atc = "amp threads continue";
    ls-scripts = "cat package.json | jq .scripts";

    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gdiff = "git diff";
    gl = "git prettylog";
    gp = "git push";
    gs = "git status";
    gt = "git tag";

    jd = "jj desc";
    jf = "jj git fetch";
    jn = "jj new";
    jp = "jj git push";
    js = "jj st";
  };

  sshKeyPath = (
    if isLinux
    then "~/.ssh/id_ed25519.pub"
    else "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  );

  dotfilesPath = "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles";
  mutableConfig = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
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
      pkgs.neovim
      # Stuff
      # CLI tools
      pkgs.alejandra
      pkgs.bat
      pkgs.btop
      pkgs.curl
      pkgs.eza
      pkgs.fd
      pkgs.file
      pkgs.fzf
      pkgs.gh
      pkgs.git-get
      pkgs.git-lfs
      pkgs.ijq
      pkgs.jj-starship
      pkgs.jq
      pkgs.vscode-json-languageserver # Json lsp 
      pkgs.lazygit
      pkgs.nix-output-monitor
      pkgs.nixd
      pkgs.repgrep
      pkgs.ripgrep
      inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.hunk
      pkgs.starship
      pkgs.tmux
      pkgs.tree
      pkgs.watch
    ]
    ++ (lib.optionals isDarwin [
      inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    ])
    ++ (lib.optionals isLinux [
      # non-darwin packages
      pkgs.usbutils
      pkgs.pciutils
      pkgs.llama-cpp
      pkgs.claude-code
      pkgs.codex
      pkgs.pi
      inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
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
    ".cargo/binstall/crates-v1.json" = {
      source = mutableConfig "stowed/.cargo/binstall/crates-v1.json";
    };
    ".cargo/config.toml" = {
      source = mutableConfig "stowed/.cargo/config.toml";
    };
    ".claude/settings.json" = {
      source = mutableConfig "users/uzaaft/claude/settings.json";
    };
    "opencode/opencode.json" = {
      source = mutableConfig "users/uzaaft/opencode.json";
    };
    ".agents/skills".source = inputs.agent-skills;
    ".claude/skills".source = inputs.agent-skills;
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
      
      niri = {
        source = mutableConfig "config/niri";
      };
      "herdr/config.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/herdr/config.toml";
      };
      nvim = {
        source = mutableConfig "config/nvim";
      };
      "nushell/config.nu" = {
        source = mutableConfig "users/uzaaft/config.nu";
      };
      "oh-my-posh/omp.json" = {
        source = mutableConfig "users/uzaaft/omp.json";
      };
      opencode = {
        source = mutableConfig "users/uzaaft/opencode";
      };
      "starship.toml" = {
        source = mutableConfig "config/starship.toml";
      };
      "tmux/sand.sh" = {
        source = mutableConfig "stowed/.config/tmux/sand.sh";
      };
      yabai = {
        source = mutableConfig "config/yabai";
      };
      zsh = {
        source = mutableConfig "config/zsh";
      };
      "lazygit/config.yml" = {
        source = mutableConfig "users/uzaaft/lazygit.yml";
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
      then {}
      else {}
    );

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.lazydocker = {enable = true;};

  programs.ghostty = {
    enable = isGraphicalLinux;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  programs.gpg.enable = !isDarwin;

  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    nix-direnv.enable = true;

    enableZshIntegration = true;

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

  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        editor = "nvim";
        diff-editor = ":builtin";
        diff-formatter = ":git";
        pager = "less -FRX";
        default-command = ["log"];
        graph.style = "curved";
      };
      template-aliases = {
        "format_short_id(id)" = "id.shortest(8)";
      };
      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "fork_history(to, from)" = "fork_point(to | from)..@";
      };
      aliases = {
        b = "branch";
        n = "new";
        tug = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"];
        retrunk = "rebase -d trunk()";
      };
      signing = {
        behavior = "own";
        backend = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      git = {
        colocate = true;
        sign-on-push = true;
      };
      templates = {
        git_push_bookmark = "\"uzaaft/\" ++ change_id.short()";
      };
      user = {
        name = "Uzair Aftab";
        email = "git@uzaaft.me";
      };
    };
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

      "gpg \"ssh\"" =
        if isDarwin
        then {program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";}
        else {};
    };
  };

  programs.vicinae = {
    enable = isGraphicalLinux;
    settings = {
      favicon_service = "twenty";
      pop_to_root_on_close = true;
      telemetry = {
        system_info = false;
      };
      theme = {
        dark = {
          name = "vicinae-dark";
        };
      };
    };
  };
}
