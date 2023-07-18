{ lib, ... }:

with lib;

{
  options = {
    martiert.zones = mkOption {
      default = {};
      description = "Config for sinkholing dns entries";
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "Enable this zone";
          ttl = mkOption {
            default = 60;
            description = "DNS ttl for all zone records";
            type = types.int;
          };
          records = mkOption {
            default = {};
            description = "DNS name entry records";
            type = types.attrsOf (types.attrsOf types.str);
          };
        };
      });
    };
  };
}
