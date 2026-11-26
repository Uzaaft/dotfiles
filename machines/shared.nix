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
        "https://uzair.snowstead.com/dotfiles"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "snowstead-1-13-0ef37d5c-56a7-4377-aa4e-7f36e4ed47fa:agLCC6+LNpb+Dox+atkxrKrx9SbWT/zgJKr5XY4T9eE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
