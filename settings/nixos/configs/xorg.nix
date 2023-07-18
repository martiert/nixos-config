{ pkgs, config, lib, ... }:

with lib;

let
  martiert = config.martiert;
  guiEnabled = builtins.elem martiert.system.type [ "desktop" "laptop" "wsl" ];
in mkIf guiEnabled {
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "caps:none,compose:lwin";

    libinput.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        enableHidpi = builtins.elem martiert.system.type [ "desktop" "laptop" ];
      };
      defaultSession = martiert.services.xserver.defaultSession;
    };

    windowManager.i3.enable = true;

    wacom.enable = true;
  };

  programs.sway.enable = true;
  hardware.opengl = mkIf (pkgs.system == "x86_64-linux") {
    driSupport32Bit = true;
  };
}
