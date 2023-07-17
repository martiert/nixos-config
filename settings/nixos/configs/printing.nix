{ pkgs, config, lib, ... }:

let
  cfg = config.martiert;
in {
  services.printing = {
    enable = cfg.printing.enable;
    drivers = [ pkgs.cnijfilter2 ];
  };
}
