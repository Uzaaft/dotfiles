{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

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
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "25.05";

  xdg.enable = true;

  # Packages I always want installed.
  home.packages =
    [
      pkgs.amp
      pkgs.codex
      pkgs.oh-my-codex
      pkgs.oh-my-openagent
      pkgs._1password-cli
      inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
      # Stuff
      # CLI tools
      pkgs.alejandra
      pkgs.asciinema
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
      pkgs.git-hunks
      pkgs.git-lfs
      pkgs.ijq
      pkgs.jq
      pkgs.lazygit
      pkgs.llama-cpp
      pkgs.nix-output-monitor
      pkgs.nixd
      pkgs.nodejs-slim_24
      pkgs.nushell
      pkgs.onefetch
      pkgs.repgrep
      pkgs.ripgrep
      pkgs.tmux
      pkgs.tree
      pkgs.watch
      inputs.helium.packages.${pkgs.system}.default
    ]
    ++ (lib.optionals isDarwin [
      ])
    ++ (lib.optionals isLinux [
      # non-darwin packages
      pkgs.usbutils
      pkgs.pciutils
      pkgs.clang
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
      amp = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/users/uzaaft/amp";
      };
      agents = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/users/uzaaft/agents";
      };
      nvim = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repositories/github.com/uzaaft/dotfiles/config/nvim";
      };
      "nushell/config.nu".text = builtins.readFile ./config.nu;
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
  programs.nh.enable = true;


  programs.lazydocker = {enable = true;};

  programs.opencode = {
    enable = true;
  };

  programs.ghostty = {
    enable = isLinux;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  programs.gpg.enable = !isDarwin;

  programs.direnv = {
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
      reset-aliases = {
        "mine()" = "author(uzaaft)";
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
        push-bookmark-prefix = "uzaaft/";
      };
      user = {
        name = "Uzair Aftab";
        email = "git@uzaaft.me";
      };
    };
  };

  programs.fuzzel.enable = isLinux;

  programs.ssh = {
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
  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = ["ignoredups" "ignorespace"];
    initExtra = builtins.readFile ./bashrc;
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

  programs.delta = {
    enableGitIntegration = true;
    # enableJujutsuIntegration = true;
    enable = true;
    options = {
      navigate = true;
      dark = true;
    };
  };

  programs.vicinae = {
    enable = isLinux;
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
