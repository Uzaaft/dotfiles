{
  inputs,
  pkgs,
  lib,
  currentSystemName,
  ...
}: let
  isDesktop = currentSystemName == "macbook-m5";
in {
  homebrew = lib.mkIf isDesktop {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = false;
      cleanup = "uninstall";
    };

    taps = [
      {
        name = "bobrwm/tap";
        trusted = true;
      }
      {
        name = "abue-ammar/tinycast";
        trusted = true;
      }
      {
        name = "steipete/tap";
        trusted = true;
      }
      # {
      #   name = "uzaaft/costbar";
      #   trusted = true;
      # }
    ];

    casks = [
      "1password"
      "alt-tab"
      "amp-app"
      "brave-browser"
      "bobrwm/tap/bobrwm"
      "chatgpt"
      "claude"
      "cloudflare-warp"
      "codexbar"
      {
        name = "ghostty@tip";
        greedy = true;
      }
      "clop"
      "discord"
      "grok-bot"
      "helium-browser"
      "hermes-desktop"
      "hiddenbar"
      "imageoptim"
      "linear"
      "logi-options+"
      "abue-ammar/tinycast/tinycast"
      "slack"
      "tableplus"
      "tailscale-app"
      "wispr-flow"
      # Required for Norwegian jobs
      "visual-studio-code"
      # CLI tools
      "codex"
      "zulip"
      {
        name = "claude-code@latest";
        greedy = true;
      }
      {
        name = "ghostty@tip";
        greedy = true;
      }
    ];
    brews = [
      "gnupg"
    ];
  };

  security.pam.services.sudo_local = lib.mkIf isDesktop {
    touchIdAuth = true;
    reattach = true;
  };

  system = {
    primaryUser = "uzaaft";
    startup = lib.mkIf isDesktop {chime = true;};
    keyboard = lib.mkIf isDesktop {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults.NSGlobalDomain = lib.mkIf isDesktop {
      NSWindowShouldDragOnGesture = true;
    };
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.uzaaft = {
    home = "/Users/uzaaft";
  };
}
