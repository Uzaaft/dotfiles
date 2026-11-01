{pkgs, ...}: {
  # https://github.com/nix-community/home-manager/pull/2408
  # imports = [
  # ];

  # Lets fish find completions from packages Home Manager installs.
  environment.pathsToLink = ["/share/fish"];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # fish is the login shell; zsh stays available.
  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

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
    extraGroups = ["wheel" "podman" "video"];
    shell = pkgs.fish;
    hashedPassword = "$6$5h.pMKRtGXli6Ix0$IW1YG5nUV9K0Z.TuXWU0E6N0maqrcWMf1exw0TgkKKDwFZ9grjBFsE.OiNCYiRW.ibuRgEeEVbAn4jrIYiwDZ0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZX17OSEH3mKJsP4oFuaGtr8F5TF/3/RXOCw2cBgps"
    ];
  };
  security.pki.caCertificateBlacklist = [
  "Comodo AAA Services root"
  ];

}
