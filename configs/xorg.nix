{ config, lib, ... }:

with lib;

let
  cfg = config.martiert.services.xserver;
in {
  options = {
    martiert.services.xserver = {
      defaultSession = mkOption {
        type = types.str;
        default = "sway";
        description = "Default session for sddm";
      };
    };
  };

  config = {
    services.xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "caps:none,compose:lwin";

      libinput.enable = true;
      displayManager = {
        sddm.enable = true;
        defaultSession = cfg.defaultSession;
      };

      windowManager.i3.enable = true;

      useGlamor = true;
      wacom.enable = true;
    };

    programs.sway.enable = true;
    hardware.opengl.driSupport32Bit = true;
  };
}
