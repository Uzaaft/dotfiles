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
    settings = {
      substituters = ["https://mitchellh-nixos-config.cachix.org" "https://nix-community.cachix.org"];
      trusted-public-keys = ["mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];

      # Required for the linux builder
      trusted-users = ["@admin"];
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
