{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware/ws-nvda-x86_64.nix
  ];
  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_zen;
  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bobr";
  time.timeZone = "Europe/Oslo";

  networking.useDHCP = false;
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    #
    settings = {
      substituters = [
        "https://mitchellh-nixos-config.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-users = ["@wheel"];
      trusted-public-keys = [
        "mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  services.tailscale.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings.features.cdi = true;
    };
    daemon.settings = {
      ipv6 = false;
      hosts = [
        "unix:///run/user/1000/docker.sock"
        "tcp://0.0.0.0:2375"
      ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    cachix
    gnumake
    killall

    (writeShellScriptBin "niri-auto" ''
      niri msg output Virtual-1 mode auto
    '')
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };
  services.xserver.videoDrivers = ["nvidia"];

  system.stateVersion = "24.11"; # Did you read the comment?

  networking.networkmanager.enable = true;
  networking.interfaces.enp7s0.useDHCP = true;
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };
  # nixpkgs.config.allowUnsupportedSystem = true;
}
