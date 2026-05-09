{
  description = "Example nix-darwin system flake";

  inputs = {
    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-stable.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
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

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
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

    hunk = {
      url = "github:uzaaft/hunk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
        git-hunks = prev.callPackage ./packages/git-hunks {};
        hunk = inputs.hunk.packages.${prev.system}.default;
        nushell = inputs.nixpkgs-stable.legacyPackages.${prev.system}.nushell;
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
        git-hunks = pkgs.callPackage ./packages/git-hunks {};
      });
    nixosConfigurations.vm-aarch64 = mkSystem "vm-aarch64" {
      system = "aarch64-linux";
      user = "uzaaft";
    };

    nixosConfigurations.latte-panda-x86_64 = mkSystem "latte-panda-x86_64" {
      system = "x86_64-linux";
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
