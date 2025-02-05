{
  pkgs,
  inputs,
  ...
}: {
  # https://github.com/nix-community/home-manager/pull/2408

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;


  users.users.uzaaft = {
    isNormalUser = true;
    home = "/home/mitchellh";
    extraGroups = [];
    shell = pkgs.uzaaft;
    # hashedPassword = "";
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbTIKIPtrymhvtTvqbU07/e7gyFJqNS4S0xlfrZLOaY mitchellh"
    # ];
  };
}
