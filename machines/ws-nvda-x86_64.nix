{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware/ws-nvda-x86_64.nix
    ../lib/amp-runners.nix
  ];
  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      dejavu_fonts
      freefont_ttf
      gyre-fonts
      liberation_ttf
      noto-fonts-color-emoji
      unifont
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  # The installer detects the older fallback EFI binary first. Allow bootctl
  # update to skip the already-current canonical binaries without failing.
  boot.loader.systemd-boot.graceful = true;
  # Adds a Memtest86+ entry to the boot menu for testing RAM.
  boot.loader.systemd-boot.memtest86.enable = true;
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
    amp-runners = {
      enable = true;
      user = "uzaaft";
      package = pkgs.amp;
      runners.dev.repos = [
        "polymath-as/solidus"
        "antithesishq/bombadil"
        "uzaaft/dotfiles"
        "Polymath-AS/odin"
        "Polymath-AS/snowstead-web"
        "polymath-as/infrastructure"
        "uzaaft/libghostty-rs"
      ];
    };
    tailscale.enable = true;
    ollama = {
      enable = false;
      package = pkgs.ollama-cuda;
      # Bind to all interfaces so the Mac (and other Tailscale peers) can
      # reach this box. Exposure is scoped to tailscale0 by the firewall
      # rule below; LAN and WAN never see port 11434.
      host = "0.0.0.0";
      port = 11434;
    };

    xserver.videoDrivers = ["amdgpu" "nvidia"];
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      flags = ["--all" "--volumes"];
    };
  };

  virtualisation.libvirtd.enable = false;
  programs.virt-manager.enable = true;
  users.users.uzaaft.extraGroups = ["libvirtd"];

  # This generator loads NVIDIA userspace libraries and talks to the loaded
  # kernel module. During a NixOS switch after a driver or kernel update, those
  # can be from different generations until the next reboot, which makes NVML
  # fail with "Driver/library version mismatch" and marks the switch failed.
  # Let the service generate CDI data at boot, when the module and libraries
  # come from the same system generation.
  systemd.services.nvidia-container-toolkit-cdi-generator.restartIfChanged = false;

  # RTX 5090: measured ~5% less Tensor Core throughput for 110 W less power.
  # Leave boost clocks and the automatic fan curve under driver control.
  systemd.services.nvidia-power-limit = {
    description = "Set RTX 5090 power limit";
    wantedBy = ["multi-user.target"];
    requires = ["nvidia-persistenced.service"];
    after = ["nvidia-persistenced.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${lib.getBin config.hardware.nvidia.package}/bin/nvidia-smi -i 00000000:01:00.0 -pl 490";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    gnumake
    killall
    qemu
    stress-ng
    gpu-burn

    (writeShellScriptBin "niri-auto" ''
      niri msg output Virtual-1 mode auto
    '')
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
  programs.niri = {
    enable = true;
    # GTK provides the portal file chooser, so Nautilus is unnecessary.
    useNautilus = false;
  };
  services.gnome.gnome-keyring.enable = false;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  networking = {
    useNetworkd = true;
    wireless.iwd = {
      enable = true;
      # iwd handles Wi-Fi association while networkd remains the sole owner
      # of addresses, routes, and DHCP.
      settings.General.EnableNetworkConfiguration = false;
    };
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-ethernet" = {
        matchConfig = {
          Type = "ether";
          Kind = "!*";
        };
        networkConfig.DHCP = "yes";
      };
      "20-wireless" = {
        matchConfig.WLANInterfaceType = "station";
        networkConfig.DHCP = "yes";
        # A disconnected Wi-Fi adapter must not block boot or activation when
        # Ethernet is the active network connection.
        linkConfig.RequiredForOnline = false;
        # Prefer Ethernet whenever both links have a default route.
        dhcpV4Config.RouteMetric = 1025;
        ipv6AcceptRAConfig.RouteMetric = 1025;
      };
    };
  };
  networking.firewall.allowedUDPPorts = [41641];
  # Expose Ollama only on the Tailscale interface.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [11434];
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  # nixpkgs.config.allowUnsupportedSystem = true;
}
