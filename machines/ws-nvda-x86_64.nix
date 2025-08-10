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
      trusted-public-keys = [
        "mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  services.tailscale.enable = true;
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
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
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.xserver.videoDrivers = ["nvidia"];

  system.stateVersion = "24.11"; # Did you read the comment?

  networking.networkmanager.enable = true;
  networking.interfaces.enp7s0.useDHCP = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;
  # nixpkgs.config.allowUnsupportedSystem = true;
}
