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
      "arc"
      "BetterDisplay"
      "alt-tab"
      "bitwarden"
      "discord"
      "hiddenbar"
      "istat-menus"
      "linear-linear"
      "monodraw"
      "orbstack"
      "slack"
      "spotify"
      "tableplus"
      "yaak"
      # Required for Norwegian jobs
      "microsoft-teams"
      "notion"
      "pycharm"
      "visual-studio-code"
      {
        name = "ghostty@tip";
        greedy = true;
      }
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
  programs.fish.enable = true;

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  system.primaryUser = "uzaaft";
  users.users.uzaaft = {
    home = "/Users/uzaaft";
    shell = pkgs.fish;
  };
}
