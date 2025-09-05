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
      "BetterDisplay"
      "alt-tab"
      "bitwarden"
      "bruno"
      "discord"
      "hiddenbar"
      "istat-menus"
      "linear-linear"
      "monodraw"
      "orbstack"
      "slack"
      "spotify"
      "tableplus"
      "vmware-fusion"
      # Required for Norwegian jobs
      "microsoft-teams"
      "notion"
      "pycharm"
      {
        name = "ghostty@tip";
        greedy = true;
      }
      # Need this for nrf development
      "visual-studio-code"
      # Testing this out to see what the hype is about
    ];
    brews = [
      "gnupg"
      "koekeishiya/formulae/yabai"
    ];
  };
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  services.yabai = {
    enable = true;
    # enableScriptAddition = true;
  };

  system = {
    startup = {chime = true;};
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
