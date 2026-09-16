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
  ];
  networking.hostName = "archmac";
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
  # ignored because nix.enable = false. Route trusted-users through the
  # determinate module so it lands in /etc/nix/nix.custom.conf.
  determinateNix.customSettings = {
    trusted-users = ["@admin" "uzaaft"];
  };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;
  services.tailscale.enable = true;

  # Keep paths inherited from GUI terminals after Nix's configured paths.
  environment.systemPath = lib.mkAfter [ "\${PATH:-/usr/bin:/bin}" ];

  environment.shells = with pkgs; [zsh];
  environment.systemPackages = with pkgs; [ ];
}
