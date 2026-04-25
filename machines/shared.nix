{
  config,
  pkgs,
  lib,
  currentSystem,
  currentSystemName,
  ...
}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    #
    settings = {
      substituters = [
        "https://odin-cache.polymath-as.workers.dev"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "odin-cache-1:d1Cfba/xH2C9GMB+B55z2kM+KbLMUl//iZiDsfkKnWU="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
