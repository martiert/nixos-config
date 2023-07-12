{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.martiert.services.xserver;
  hwCfg = config.martiert.hardware;
in {
  options = {
    martiert.services.xserver = {
      enable = mkEnableOption "Enable xserver";
      defaultSession = mkOption {
        type = types.str;
        default = "sway";
        description = "Default session for sddm";
      };
    };
    martiert.hardware.hidpi.enable = mkEnableOption "Enable hidpi mode";
  };

  config = {
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
  };
}
