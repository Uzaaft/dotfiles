{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware/vm-aarch64.nix
    ../modules/vmware-guest.nix
    ./vm-shared.nix
  ];

  # Setup qemu so we can run x86_64 binaries
  boot.binfmt.emulatedSystems = ["x86_64-linux"];

  # Disable the default module and import our override. We have
  # customizations to make this work on aarch64.
  disabledModules = ["virtualisation/vmware-guest.nix"];

  # Interface is this on M1
  networking.interfaces.ens160.useDHCP = true;

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnsupportedSystem = true;

  # This works through our custom module imported above
  virtualisation.vmware.guest.enable = true;

  services.greetd = {
    enable = true;
    package = pkgs.greetd.tuigreet;
    settings = {
      # terminal = {
      #   vt = 1;
      # };
      default_session = {
        user = "uzaaft";
        command = "${lib.getExe pkgs.greetd.tuigreet} --cmd ${lib.getExe' pkgs.niri "niri-session"}";
      };
    };
  };

  # Share our host filesystem
}
