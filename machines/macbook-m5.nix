{...}: {
  imports = [./darwin-shared.nix];

  networking = {
    hostName = "macbook-m5";
    localHostName = "macbook-m5";
    computerName = "macbook-m5";
  };
}
