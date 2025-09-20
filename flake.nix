{
  description = "Example nix-darwin system flake";

  inputs = {
    # We use the unstable nixpkgs repo for some packages.
    # nixpkgs.url = "https://channels.nixos.org/nixos-25.05/nixexprs.tar.xz";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    # Spesific nixpkgs for darwin as recommended by nix-darwin docs.
    nixpkgs-darwin.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

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

    nix-ai-tools.url = "github:numtide/nix-ai-tools";
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
      inputs.ghostty.overlays.default

      (final: prev: {})
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
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
