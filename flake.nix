{
  description = "Bobr System Flake";

  inputs = {
    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    # Spesific nixpkgs for darwin as recommended by nix-darwin docs.

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helios = {
      url = "github:Polymath-AS/helios";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    
    opencode = {
      url = "github:anomalyco/opencode/60c88336b9430b8a516c6a44884e3fbf45dc2f62";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bmux = {
      url = "github:uzaaft/bmux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi-config = {
      url = "git+https://code.mehalter.com/mehalter/pi";
      flake = false;
    };
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
      (final: prev: {
        amp = prev.callPackage ./packages/amp {};
        claude-code = prev.callPackage ./packages/claude-code {};
        pi = prev.callPackage ./packages/pi {};
        tmux = inputs.bmux.packages.${prev.stdenv.hostPlatform.system}.default;
      })
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
    # Expose amp package
    packages =
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ] (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        amp = pkgs.callPackage ./packages/amp {};
        claude-code = pkgs.callPackage ./packages/claude-code {};
        git-hunks = pkgs.callPackage ./packages/git-hunks {};
        pi = pkgs.callPackage ./packages/pi {};
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
