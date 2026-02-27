{
  inputs,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = false;
      cleanup = "uninstall";
    };

    taps = ["koekeishiya/formulae"];

    casks = [
      "1password"
      "BetterDisplay"
      "alt-tab"
      "arc"
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
      # Required for Norwegian jobs
      "helium-browser"
      "microsoft-teams"
      "notion"
      "proton-mail"
      "pycharm"
      "raycast"
      "visual-studio-code"
      "wispr-flow"
      {
        name = "ghostty@tip";
        greedy = true;
      }
    ];
    brews = [
      "gnupg"
      "koekeishiya/formulae/yabai"
      "zig"
    ];
  };
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
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
    shell = pkgs.zsh;
  };
}
