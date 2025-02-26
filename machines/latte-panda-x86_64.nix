{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware/latte-panda-x86_64.nix
    ./ws-shared.nix
  ];

  # Setup qemu so we can run x86_64 binaries

  # Disable the default module and import our override. We have
  # customizations to make this work on aarch64.

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnsupportedSystem = true;
}
