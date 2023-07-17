{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.martiert.services.xserver;
  hwCfg = config.martiert.hardware;
in {
  services.xserver = mkIf cfg.enable {
    enable = cfg.enable;
    layout = "us";
    xkbOptions = "caps:none,compose:lwin";

    libinput.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        enableHidpi = hwCfg.hidpi.enable;
      };
      defaultSession = cfg.defaultSession;
    };

    windowManager.i3.enable = true;

    wacom.enable = true;
  };

  programs.sway.enable = cfg.enable;
  hardware.opengl = mkIf (pkgs.system == "x86_64-linux") {
    driSupport32Bit = cfg.enable;
  };
}
