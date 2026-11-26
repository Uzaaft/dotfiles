{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Set in Sept 2024 as part of the macOS Sequoia release.
  imports = [
    ./shared.nix
    ./darwin-nushell.nix
  ];
  system.stateVersion = 5;
  nixpkgs.config.allowUnfree = true;

  nix = {
    enable = false;

    # We need to enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      trusted-users = ["@admin" "uzaaft"];
    };
  };

  # Determinate Nix manages /etc/nix/nix.conf itself; nix.settings above is
  # ignored because nix.enable = false. Route settings through the determinate
  # module so they land in /etc/nix/nix.custom.conf.
  determinateNix.customSettings = {
    trusted-users = ["@admin" "uzaaft"];
    # extra-* keeps cache.nixos.org; replacing it forces source builds.
    extra-substituters = ["https://uzair.snowstead.com/dotfiles"];
    extra-trusted-public-keys = [
      "snowstead-1-13-0ef37d5c-56a7-4377-aa4e-7f36e4ed47fa:agLCC6+LNpb+Dox+atkxrKrx9SbWT/zgJKr5XY4T9eE="
    ];
  };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

  # Keep paths inherited from GUI terminals after Nix's configured paths.
  environment.systemPath = lib.mkAfter ["\${PATH:-/usr/bin:/bin}"];

  environment.shells = with pkgs; [zsh ];
  environment.systemPackages = with pkgs; [];
}
