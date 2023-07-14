{ pkgs, lib, ...}:

{
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "martin";
    startMenuLaunchers = false;
  };
}
