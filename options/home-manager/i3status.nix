{ pkgs, lib, ... }:

with lib;

{
  options = {
    martiert = {
      i3status = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        extraDisks = mkOption {
          type = types.attrsOf types.str;
          default = {};
        };
      };
      i3 = {
        enable = mkEnableOption "Enable i3";
        lockCmd = mkOption {
          type = types.str;
          default = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
          description = "Screen locking cmd";
        };
        barSize = mkOption {
          type = types.float;
          default = 14.0;
          description = "Font size for bars";
        };
      };
    };
  };
}
