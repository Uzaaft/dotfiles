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

    taps = ["koekeishiya/formulae" "polymath-as/bobrvm" "uzaaft/costbar"];

    casks = [
      "1password"
      "BetterDisplay"
      "alt-tab"
      "arc"
      "brave-browser"
      "chatgpt"
      "claude"
      "codexbar"
      {
        name = "ghostty@tip";
        greedy = true;
      }
      "clop"
      "discord"
      "grokbot"
      "helium-browser"
      "hermes-desktop"
      "hiddenbar"
      "imageoptim"
      "linear"
      "logi-options+"
      "raycast"
      "slack"
      "tableplus"
      "wispr-flow"
      # Required for Norwegian jobs
      "microsoft-teams"
      "visual-studio-code"
      # CLI tools
      "codex"
      {
        name = "claude-code@latest";
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
