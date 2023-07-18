{ lib, config, ...}:

let
  martiert = config.martiert;
in {
  wsl = lib.mkIf (martiert.system.type == "wsl") {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "martin";
    startMenuLaunchers = false;
  };
}
