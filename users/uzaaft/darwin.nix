{
  inputs,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;
    taps = ["koekeishiya/formulae"];

    casks = [
      "1password"
      "discord"
      "vmware-fusion"
      "BetterDisplay"
      "alt-tab"
      "orbstack"
      "bruno"
      "tableplus"
      "spotify"
      # Required for Norwegian jobs
      "microsoft-teams"
      {
        name = "ghostty@tip";
        greedy = true;
      }
      "linear-linear"
      # Required for startup
      "slack"
      # Need this for nrf development
      "visual-studio-code"
      "nrf-connect"
      "segger-jlink"
      "nordic-nrf-command-line-tools"
      # Testing this out to see what the hype is about
      "windsurf"
    ];
    brews = [
      "koekeishiya/formulae/yabai"
    ];
  };
  nix.enable = false;
  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  system.primaryUser = "uzaaft";
  users.users.uzaaft = {
    home = "/Users/uzaaft";
  };
}
