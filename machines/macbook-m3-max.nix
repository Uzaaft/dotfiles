{
  config,
  inputs,
  pkgs,
  ...
}: let
  home = config.users.users.uzaaft.home;
  rex = inputs.rex.packages.${pkgs.stdenv.hostPlatform.system}.rex;
in {
  imports = [./darwin-shared.nix];

  # Keep the OS and embedded Rex server on separate Tailscale DNS names.
  networking = {
    hostName = "macbook-m3-max";
    localHostName = "macbook-m3-max";
    computerName = "macbook-m3-max";
  };

  # An unattended agent runner, following mitchellh's headless Mac profile.
  # Mac notebooks do not support restartAfterPowerFailure.
  power = {
    sleep.computer = "never";
    restartAfterFreeze = true;
  };

  # Start Tailscale before login on this headless machine.
  services.tailscale = {
    enable = true;
    overrideLocalDns = true;
  };

  # Start in the system domain, but run all sessions as the existing user.
  # Keep the default user state and socket so the existing sessions and
  # embedded Tailscale identity can be reused during the planned handoff.
  launchd.daemons.rex = {
    environment = {
      HOME = home;
      USER = "uzaaft";
      LOGNAME = "uzaaft";
      TERMINFO_DIRS = "${rex}/share/terminfo:";
    };
    path = [
      "/etc/profiles/per-user/uzaaft/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"
      "${home}/.local/bin"
      "/opt/homebrew/bin"
      "/usr/bin"
      "/bin"
      "/usr/sbin"
      "/sbin"
    ];
    serviceConfig = {
      UserName = "uzaaft";
      WorkingDirectory = home;
      ProgramArguments = [
        "${rex}/bin/rex"
        "server"
        "run"
        "--listen"
        "unix://${home}/Library/Application%20Support/rex/server.sock"
        "--config"
        "${home}/.config/rex/init.lua"
        "--tailscale"
        "--tailscale-hostname"
        "macbook-m3-max-rex"
        "--websocket-origin-pattern"
        "https://rex.superlogical.com"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      Umask = 63; # 0077: private sockets and state.
      StandardOutPath = "/var/log/rex.log";
      StandardErrorPath = "/var/log/rex.log";
    };
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PermitRootLogin no
    '';
  };
}
