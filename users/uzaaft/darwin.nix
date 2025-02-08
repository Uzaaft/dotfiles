{
  inputs,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;
    casks = [];
  };
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.uzaaft = {
    home = "/Users/uzaaft";
  };
}
