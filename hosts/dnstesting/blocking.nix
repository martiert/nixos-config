{ pkgs, lib, config, ... }:

let
  makeEntry = type: ttl: domain: destination: "${domain} ${builtins.toString ttl} ${type} ${destination}";
  makeRecordType = ttl: type: value:
    builtins.concatStringsSep "\n" (lib.mapAttrsToList (makeEntry type ttl) value);
  generateRecords = ttl: records: builtins.concatStringsSep "\n" (lib.mapAttrsToList (makeRecordType ttl) records);

  makeZone = name: values: {
    master = true;
    file = pkgs.writeTextFile {
      name = "${name}.zone";
      text = ''$ORIGIN ${name}.
@   3600  SOA ns1.example.com. (
            zone-admin.example.com.
            2016071232
            3600
            600
            604800
            1800)
    86400 NS ns1.example.com.
${generateRecords values.ttl values.records}
    '';
    };
  };
  generateZones = zones:
    builtins.mapAttrs makeZone (lib.filterAttrs (_: value: value.enable) zones);
in {
  options = with lib; {
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

  config = {
    services.bind = {
      enable = true;
      ipv4Only = true;
      cacheNetworks = [
        "0.0.0.0/0"
      ];
      forwarders = [
        "8.8.8.8"
        "1.1.1.1"
      ];
      zones = generateZones config.martiert.zones;
    };
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
