{
  description = "Bobr System Flake";

  inputs = {
    # We use the unstable nixpkgs repo for some packages.
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    # Spesific nixpkgs for darwin as recommended by nix-darwin docs.

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:uzaaft/ghostty/push-xpztrnpxmwmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jj-get = {
      url = "github:uzaaft/jj-get";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      (final: prev: let
        system = prev.stdenv.hostPlatform.system;
        unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        xdgDesktopPortalWithoutGeoLocation =
          (prev.xdg-desktop-portal.override {
            enableGeoLocation = false;
          }).overrideAttrs (_: {
            doCheck = false;
          });
        gstPluginsBadWithoutFlite = prev.gst_all_1.gst-plugins-bad.overrideAttrs (old: {
          buildInputs = prev.lib.filter (dependency: dependency != prev.flite) old.buildInputs;
          mesonFlags = old.mesonFlags ++ ["-Dflite=disabled"];
        });
        gtk4WithoutFlite = prev.gtk4.override {
          gst_all_1 =
            prev.gst_all_1
            // {
              gst-plugins-bad = gstPluginsBadWithoutFlite;
            };
        };
      in {
        xdg-desktop-portal = xdgDesktopPortalWithoutGeoLocation;
        xdg-desktop-portal-gnome = prev.xdg-desktop-portal-gnome.override {
          gtk4 = gtk4WithoutFlite;
          xdg-desktop-portal = xdgDesktopPortalWithoutGeoLocation;
        };
        amp = prev.callPackage ./packages/amp {};
        claude-code = prev.callPackage ./packages/claude-code {};
        codex = prev.callPackage ./packages/codex {};
        opencode = prev.callPackage ./packages/opencode {};
        jj-get = inputs.jj-get.packages.${system}.jj-get;
      })
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
    # Expose local packages
    packages =
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        amp = pkgs.callPackage ./packages/amp {};
        claude-code = pkgs.callPackage ./packages/claude-code {};
        codex = pkgs.callPackage ./packages/codex {};
        opencode = pkgs.callPackage ./packages/opencode {};
      });
    nixosConfigurations.vm-aarch64 = mkSystem "vm-aarch64" {
      system = "aarch64-linux";
      user = "uzaaft";
    };

    nixosConfigurations.nvidia-workstation = mkSystem "ws-nvda-x86_64" {
      system = "x86_64-linux";
      user = "uzaaft";
    };

    darwinConfigurations.ArchMac = mkSystem "macbook" {
      system = "aarch64-darwin";
      user = "uzaaft";
      darwin = true;
    };
  };
}
