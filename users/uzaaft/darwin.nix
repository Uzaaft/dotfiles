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
      "claude-code"
      "codex"
      "codexbar"
      "discord"
      "font-ioskeley-mono"
      "helium-browser"
      "hiddenbar"
      "istat-menus"
      "linear"
      "logi-options+"
      "monodraw"
      "orbstack"
      "sioyek"
      "slack"
      "spotify"
      "tableplus"
      # Required for Norwegian jobs
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
      "zig"
      "opencode"
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
