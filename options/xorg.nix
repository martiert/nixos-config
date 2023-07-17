{ lib, configs, ... }:

with lib;

{
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
}
