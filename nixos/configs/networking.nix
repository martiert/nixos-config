{ pkgs, lib, config, ...}:

with lib;

let
  tables = config.martiert.networking.tables;

  createTableEntry = name: data: (toString data.number) + " ${name}";
  makeIfCheck = command: ''
      if out=$(${command} 2>&1); then
        echo "done"
      elif ! echo "$out" | grep "File exists" >/dev/null 2>&1; then
        echo "'${command}' failed: $out"
        exit 1
      fi
    '';
  createRule = table: type: rule: if rule != null then 
    (makeIfCheck "ip rule add ${type} ${rule} table ${table}")
    else "";
  createRules = table: rule: concatStringsSep "\n" (mapAttrsToList (createRule table) rule);
  createRuleFromData = table: data: concatStringsSep "\n" (map (createRules table) data.rules);
  rules = concatStringsSep "\n" (mapAttrsToList createRuleFromData tables);
  

  createRoutes = table: name: route: makeIfCheck "ip route add ${name} ${route.value} table ${table}";
  createRoutesFromTable = table: data: concatStringsSep "\n" (mapAttrsToList (createRoutes table) data.routes);
  routes = concatStringsSep "\n" (mapAttrsToList createRoutesFromTable tables);

  script = concatStringsSep "\n" [ rules routes ];

  interfaces = config.martiert.networking.interfaces;
  enabled_interfaces = lib.filterAttrs (_: value: value.enable) interfaces;
  supplicant_interfaces = lib.filterAttrs (_: value: value.supplicant.enable) enabled_interfaces;

  supplicantConfig = iface: values: {
    configFile.path = config.age.secrets."wpa_supplicant_${iface}".path;
    userControlled.enable = !values.supplicant.wired;
    extraConf = if values.supplicant.wired then "" else ''
      ap_scan=1
      p2p_disabled=1
    '';
    driver = if values.supplicant.wired then "wired" else "nl80211,wext";
  };
  supplicant_config = builtins.mapAttrs supplicantConfig supplicant_interfaces;
  ifaceConfig = iface: value: {
    useDHCP = if (builtins.hasAttr "useDHCP" value) then value.useDHCP else false;
    ipv4.routes = mkIf value.staticRoutes [
      { address = "10.0.0.0";         prefixLength = 8;  }
      { address = "148.62.0.0";       prefixLength = 16; }
      { address = "149.96.17.138";    prefixLength = 32; }
      { address = "171.68.194.0";     prefixLength = 24; }
      { address = "171.70.0.0";       prefixLength = 16; }
      { address = "171.71.0.0";       prefixLength = 16; }
      { address = "173.36.0.0";       prefixLength = 16; }
      { address = "173.37.0.0";       prefixLength = 16; }
      { address = "173.38.0.0";       prefixLength = 16; }
      { address = "20.190.128.0";     prefixLength = 18; }
      { address = "20.190.129.0";     prefixLength = 24; }
      { address = "40.126.0.0";       prefixLength = 18; }
      { address = "40.126.1.0";       prefixLength = 24; }
      { address = "64.101.0.0";       prefixLength = 16; }
      { address = "64.102.0.0";       prefixLength = 16; }
      { address = "64.103.0.0";       prefixLength = 16; }
      { address = "72.163.0.0";       prefixLength = 16; }
      { address = "64.100.37.70";     prefixLength = 32; }
    ];
    ipv6.routes = mkIf value.staticRoutes [
      { address = "2603:1006:2000::";   prefixLength = 48; }
      { address = "2603:1007:200::";    prefixLength = 48; }
      { address = "2603:1016:1400::";   prefixLength = 48; }
      { address = "2603:1017::";        prefixLength = 48; }
      { address = "2603:1026:3000::";   prefixLength = 48; }
      { address = "2603:1027:1::";      prefixLength = 48; }
      { address = "2603:1036:3000::";   prefixLength = 48; }
      { address = "2603:1037:1::";      prefixLength = 48; }
      { address = "2603:1046:2000::";   prefixLength = 48; }
      { address = "2603:1047:1::";      prefixLength = 48; }
      { address = "2603:1056:2000::";   prefixLength = 48; }
      { address = "2603:1057:2::";      prefixLength = 48; }
    ];
  };
  interface_config = builtins.mapAttrs ifaceConfig enabled_interfaces;
in {
  options = {
    martiert.networking = {
      interfaces = mkOption {
        default = {};
        description = "Config for network interface";
        type = types.attrsOf (types.submodule {
          options = {
            enable = mkEnableOption "interface";
            useDHCP = mkEnableOption "dhcp for this interface";
            staticRoutes = mkEnableOption "static routes";
            supplicant = mkOption {
              default = {};
              type = types.submodule {
                options = {
                  enable = mkEnableOption "wpa_supplicant for this interface";
                  wired = mkEnableOption "wired supplicant config";
                };
              };
            };
          };
        });
      };
      tables = mkOption {
        default = {};
        description = "Tables to set up";
        type = types.attrsOf (types.submodule {
          options = {
            enable = mkEnableOption "Enable this table";
            number = mkOption {
              type = types.int;
              description = "Number to assign for this table";
            };
            rules = mkOption {
              default = [];
              type = types.listOf (types.submodule {
                options = {
                  from = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Create a rule from this ip range";
                  };
                  iff = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Create a rule from this network interface";
                  };
                  off = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Create a rule to this network interface";
                  };
                };
              });
              description = "Rule for this table";
            };
            routes = mkOption {
              default = {};
              type = types.attrsOf (types.submodule ({ name, ...}: {
                options = {
                  name = mkOption {
                    visible = false;
                    default = name;
                    type = types.str;
                    description = "Create a route for this range";
                  };
                  value = mkOption {
                    type = types.str;
                    description = "Route to where";
                  };
                };
              }));
              description = "Routes for this table";
            };
          };
        });
      };
    };
  };
  config = {
    networking.iproute2 = {
      enable = true;
      rttablesExtraConfig = concatStringsSep "\n" (mapAttrsToList createTableEntry tables) + "\n";
    };

    networking.useDHCP = false;
    networking.interfaces = interface_config;
    networking.supplicant = supplicant_config;

    systemd.services.setuptables = {
      after = [ "NetworkManager-wait-online.service" ];
      wantedBy = [ "multi-user.target" ];
      script = script;
      path = [ pkgs.iproute2 ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
