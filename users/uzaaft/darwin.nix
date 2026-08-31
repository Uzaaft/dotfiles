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
      "brave-browser"
      "chatgpt"
      "claude"
      {
        name = "claude-code@latest";
        greedy = true;
      }
      "clop"
      "codex"
      "codexbar"
      "discord"
      "helium-browser"
      "hiddenbar"
      "hermes-desktop"
      "imageoptim"
      "linear"
      "logi-options+"
      "monodraw"
      "orbstack"
      "proton-mail"
      "sioyek"
      "slack"
      "spotify"
      "tableplus"
      "wispr-flow"
      # Required for Norwegian jobs
      "microsoft-teams"
      "raycast"
      "visual-studio-code"
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
