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
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Periodic TRIM for the NVMe SSD.
  services.fstrim.enable = true;
  services.speechd.enable = false;
  services.pipewire.enable = false;

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
        "https://cache.nixos-cuda.org"

      ];
      trusted-users = ["@wheel"];
      trusted-public-keys = [
        "mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="

      ];
    };
  };

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;
  services = {
    tailscale.enable = true;
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      # Bind to all interfaces so the Mac (and other Tailscale peers) can
      # reach this box. Exposure is scoped to tailscale0 by the firewall
      # rule below; LAN and WAN never see port 11434.
      host = "0.0.0.0";
      port = 11434;
    };

    xserver.videoDrivers = ["nvidia"];
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };

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

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.uzaaft.extraGroups = ["libvirtd"];

  # This generator loads NVIDIA userspace libraries and talks to the loaded
  # kernel module. During a NixOS switch after a driver or kernel update, those
  # can be from different generations until the next reboot, which makes NVML
  # fail with "Driver/library version mismatch" and marks the switch failed.
  # Let the service generate CDI data at boot, when the module and libraries
  # come from the same system generation.
  systemd.services.nvidia-container-toolkit-cdi-generator.restartIfChanged = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    dnsmasq
    gnumake
    killall
    qemu

    (writeShellScriptBin "niri-auto" ''
      niri msg output Virtual-1 mode auto
    '')
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
  programs.niri.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  networking.networkmanager.enable = true;
  networking.interfaces.enp7s0.useDHCP = true;
  networking.firewall.allowedUDPPorts = [41641];
  networking.firewall.trustedInterfaces = ["virbr0"];
  # Expose Ollama only on the Tailscale interface.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [11434];
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  # nixpkgs.config.allowUnsupportedSystem = true;
}
