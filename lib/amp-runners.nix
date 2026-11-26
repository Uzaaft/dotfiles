{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.amp-runners;
  home = config.users.users.${cfg.user}.home;
  repoType = lib.types.strMatching "[A-Za-z0-9_-][A-Za-z0-9_.-]*/[A-Za-z0-9_-][A-Za-z0-9_.-]*";
in {
  options.services.amp-runners = {
    enable = lib.mkEnableOption "Amp headless runner services";

    user = lib.mkOption {
      type = lib.types.str;
      description = "Existing non-root user whose repositories and Amp login the runners use.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = "Amp CLI package, for example pkgs.amp from your overlay.";
    };

    repositoriesRoot = lib.mkOption {
      type = lib.types.strMatching "/.*";
      default = "${home}/repositories/github.com";
      defaultText = "$HOME/repositories/github.com";
      description = "Absolute directory containing owner/repo checkouts. Repositories must already exist.";
    };

    runners = lib.mkOption {
      default = {};
      description = "Named runners, each serving only its selected repositories at startup.";
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          id = lib.mkOption {
            type = lib.types.strMatching "[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?";
            default = "${config.networking.hostName}-${name}";
            description = "Stable Amp runner ID (a hostname label, at most 63 characters); use distinct IDs across machines.";
          };

          repos = lib.mkOption {
            type = lib.types.listOf repoType;
            example = ["polymath-as/solidus" "uzaaft/dotfiles"];
            description = "Non-empty list of owner/repo names beneath repositoriesRoot.";
          };
        };
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      [
        {
          assertion = cfg.user != "root" && config.users.users.${cfg.user}.isNormalUser;
          message = "services.amp-runners.user must be an existing normal, non-root user.";
        }
        {
          assertion = lib.length (lib.unique (map (runner: lib.toLower runner.id) (lib.attrValues cfg.runners))) == lib.length (lib.attrValues cfg.runners);
          message = "services.amp-runners: runner IDs must be unique (case-insensitive).";
        }
      ]
      ++ lib.mapAttrsToList (name: runner: {
        assertion = builtins.match "[a-zA-Z0-9_-]+" name != null && runner.repos != [];
        message = "services.amp-runners: runner ${name} needs a safe service name and at least one repository.";
      })
      cfg.runners;

    systemd.services = lib.mapAttrs' (name: runner: let
      directories = map (repo: "${cfg.repositoriesRoot}/${repo}") runner.repos;
    in
      lib.nameValuePair "amp-runner-${name}" {
        description = "Amp runner ${runner.id}";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        after = ["network-online.target"];
        unitConfig.RequiresMountsFor = [home cfg.repositoriesRoot];

        # A system service does not inherit the user's interactive shell PATH.
        # Keep their installed tools available alongside the basic runner tools.
        path = [
          pkgs.git
          pkgs.jujutsu
          pkgs.nix
          pkgs.bash
          pkgs.openssh
          pkgs.coreutils
          "${home}/.nix-profile"
          "/etc/profiles/per-user/${cfg.user}"
          "/run/current-system/sw"
        ];
        environment.HOME = home;

        preStart =
          lib.concatMapStringsSep "\n" (directory: ''
            if [ ! -d ${lib.escapeShellArg directory} ]; then
              echo ${lib.escapeShellArg "Amp repository directory does not exist: ${directory}"} >&2
              exit 1
            fi
          '')
          directories;

        serviceConfig = {
          User = cfg.user;
          WorkingDirectory = builtins.head directories;
          ExecStart = utils.escapeSystemdExecArgs (
            ["${cfg.package}/bin/amp" "--no-tui" "--runner-id" runner.id "--no-serve-cwd"]
            ++ lib.concatMap (directory: ["--dir" directory]) directories
          );
          Restart = "always";
          RestartSec = 10;
          KillMode = "control-group";
          TimeoutStopSec = 60;
          UMask = "0077";
        };
      })
    cfg.runners;
  };
}
