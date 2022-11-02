{ pkgs, lib, ...}:

{
  imports = [
    ./allowedPackages.nix
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "martin";
    startMenuLaunchers = false;
  };
}
