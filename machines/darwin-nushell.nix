# Makes Nushell the login shell on our Macs.
{lib, pkgs, ...}: {
  # nix-darwin only changes the shell of known users. Both Macs use the
  # first account created by the macOS installer (uid 501).
  users.knownUsers = ["uzaaft"];
  users.users.uzaaft = {
    uid = 501;
    shell = pkgs.nushell;
  };
  environment.shells = lib.mkAfter [pkgs.nushell];

  # A login shell starts without XDG_CONFIG_HOME. Use the same Home Manager
  # config whether Nushell discovers its native macOS or XDG directory.
  home-manager.users.uzaaft = {config, ...}: {
    home.file."Library/Application Support/nushell".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nushell";
  };
}
