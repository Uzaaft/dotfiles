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

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:uzaaft/ghostty/push-xpztrnpxmwmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # bmux = {
    #   url = "github:uzaaft/bmux";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
      in {
        amp = prev.callPackage ./packages/amp {};
        claude-code = prev.callPackage ./packages/claude-code {};
        codex = prev.callPackage ./packages/codex {};
        # tmux = inputs.bmux.packages.${prev.stdenv.hostPlatform.system}.default;
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
        git-hunks = pkgs.callPackage ./packages/git-hunks {};
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
