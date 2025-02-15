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
    home = "/home/uzaaft";
    extraGroups = [];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$.Mxn9oR73.QjxJP4G3Tpl0$Qan8YAnO8.PScXdDR3Y1QdyyKzO3uG/RgL8x1EGk1k9";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps"
    ];
  };
}
