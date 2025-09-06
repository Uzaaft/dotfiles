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
        "https://mitchellh-nixos-config.cachix.org"
        "https://nix-community.cachix.org"
        "https://uzaaft-nixos-config.cachix.org"
      ];
      extra-trusted-public-keys = [
        "mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "uzaaft-nixos-config.cachix.org-1:Aq0SI5W8qOROEbbYHS2rfukZpaDmFsjYAfQGDyJE/Pw="
      ];
    };
  };
}
