{
  inputs,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;
    taps = ["koekeishiya/formulae"];

    casks = ["1password" "discord" "vmware-fusion" "microsoft-teams" "ghostty@tip" "linear-linear"];
    brews = [
      "koekeishiya/formulae/yabai"
    ];
  };
  nix.enable = false;
  security.pam.enableSudoTouchIdAuth = true;
  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.uzaaft = {
    home = "/Users/uzaaft";
  };
}
