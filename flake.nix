{
  description = "Example nix-darwin system flake";

  inputs = {
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    darwin,
    home-manager,
    nixpkgs,
    flake-parts,
  } @ inputs: let
    username = "uzaaft";
    darwin-system = import ./system/darwin.nix {inherit inputs username;};
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin"];
      flake = {
        darwinConfigurations = {
          ArchMac = darwin-system "aarch64-darwin";
        };

        lib = import ./lib {inherit inputs;};
      };
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = {
          mono-lisa = self.lib.mono-lisa {inherit (pkgs) stdenvNoCC;};
          catppuccin-tmux = self.lib.catppuccin-tmux {
            inherit (pkgs.tmuxPlugins) mkTmuxPlugin;
            inherit (pkgs) fetchFromGitHub;
          };
        };
      };
    };
}
