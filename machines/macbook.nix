{
  config,
  pkgs,
  ...
}: {
  # Set in Sept 2024 as part of the macOS Sequoia release.
  imports = [
    ./shared.nix
  ];
  networking.hostName = "archmac";
  system.stateVersion = 5;

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

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  services.tailscale.enable = true;

  environment.shells = with pkgs; [zsh];
  environment.systemPackages = with pkgs; [
    cachix
  ];
}
