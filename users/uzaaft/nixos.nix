{
  pkgs,
  inputs,
  ...
}: {
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = ["/share/fish"];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.fish = {
    enable = true;
    package = pkgs.fish;
  };

  users.users.uzaaft = {
    isNormalUser = true;
    home = "/home/uzaaft";
    extraGroups = ["wheel"];
    shell = pkgs.fish;
    hashedPassword = "$6$5h.pMKRtGXli6Ix0$IW1YG5nUV9K0Z.TuXWU0E6N0maqrcWMf1exw0TgkKKDwFZ9grjBFsE.OiNCYiRW.ibuRgEeEVbAn4jrIYiwDZ0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps"
    ];
  };
}
