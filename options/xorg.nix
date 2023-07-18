{ lib, configs, ... }:

with lib;

{
  options = {
    martiert.services.xserver = {
      defaultSession = mkOption {
        type = types.str;
        default = "sway";
        description = "Default session for sddm";
      };
    };
  };
}
