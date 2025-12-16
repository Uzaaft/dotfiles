{
  pkgs,
  inputs,
  ...
}: {
  # https://github.com/nix-community/home-manager/pull/2408
  # imports = [
  # ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  programs.zsh.enable = true;

  # We require this because we use lazy.nvim against the best wishes
  # a pure Nix system so this lets those unpatched binaries run.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  users.users.uzaaft = {
    isNormalUser = true;
    home = "/home/uzaaft";
    extraGroups = ["wheel" "docker" "networkmanager" "video"];
    shell = pkgs.zsh;
    hashedPassword = "$6$5h.pMKRtGXli6Ix0$IW1YG5nUV9K0Z.TuXWU0E6N0maqrcWMf1exw0TgkKKDwFZ9grjBFsE.OiNCYiRW.ibuRgEeEVbAn4jrIYiwDZ0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps"
    ];
  };
}
