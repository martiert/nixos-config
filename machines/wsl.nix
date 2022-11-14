{ pkgs, lib, ...}:

{
  imports = [
    ./allowedPackages.nix
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "martin";
    startMenuLaunchers = false;
  };
}
