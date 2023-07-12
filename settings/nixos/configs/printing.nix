{ pkgs, config, lib, ... }:

let
  cfg = config.martiert;
in {
  options = {
    martiert.printing.enable = lib.mkEnableOption "Enable printing for this device";
  };

  config = {
    services.printing = {
      enable = cfg.printing.enable;
      drivers = [ pkgs.cnijfilter2 ];
    };
  };
}
