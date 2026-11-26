{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware/vm-aarch64.nix
    ./vm-shared.nix
  ];

  # Setup qemu so we can run x86_64 binaries
  boot.binfmt.emulatedSystems = ["x86_64-linux"];

  # VMware NIC naming can vary by virtual device and udev rules across installs.
  # Keep DHCP enabled for both observed names so networking survives host/VM changes.
  networking.interfaces.ens160.useDHCP = true;
  networking.interfaces.enp2s0.useDHCP = true;
  systemd.network.enable = true;
  networking.useNetworkd = true;

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnsupportedSystem = true;

  virtualisation.vmware.guest.enable = true;

  # Share our host filesystem
}
