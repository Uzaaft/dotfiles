{
  config,
  pkgs,
  ...
}: {
  # Set in Sept 2024 as part of the macOS Sequoia release.
  system.stateVersion = 5;

  nix = {
    # We need to enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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
