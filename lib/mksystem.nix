# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  nixpkgs,
  overlays,
  inputs,
}: name: {
  system,
  user,
  darwin ? false,
}: let
  # The config files for this system.
  machineConfig = ../machines/${name}.nix;
  userOSConfig =
    ../users/${user}/${
      if darwin
      then "darwin"
      else "nixos"
    }.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  # NixOS vs nix-darwin functionst
  systemFunc =
    if darwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
in
  systemFunc rec {
    inherit system;

    modules = [
      # Bring in determinate nix module if none darwin system
      (
        if darwin
        then inputs.determinate.darwinModules.default
        else inputs.determinate.nixosModules.default
      )
      (
        if darwin
        then inputs.nix-homebrew.darwinModules.nix-homebrew
        else {}
      )

      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}

      # Allow unfree packages.
      {nixpkgs.config.allowUnfree = true;}

      machineConfig
      userOSConfig
      home-manager.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.users.${user} = import userHMConfig {
          inputs = inputs;
        };
      }

      # We expose some extra arguments so that our modules can parameterize
      # better based on these values.
      {
        config._module.args = {
          currentSystem = system;
          currentSystemName = name;
          currentSystemUser = user;
          inputs = inputs;
        };
      }
    ];
  }
