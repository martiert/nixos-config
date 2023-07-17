{ lib, ... }:

with lib;

{
  options = {
    martiert.i3status = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      networks = mkOption {
        default = {
          ethernet = [];
          wireless = [];
        };
        type = types.submodule {
          options = {
            ethernet = mkOption {
              type = types.listOf types.str;
              default = [];
            };
            wireless = mkOption {
              type = types.listOf types.str;
              default = [];
            };
          };
        };
      };
      extraDisks = mkOption {
        type = types.attrsOf types.str;
        default = {};
      };
    };
  };
}
