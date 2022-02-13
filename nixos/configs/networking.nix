{ pkgs, lib, config, ...}:

with lib;

let
  tables = config.martiert.networking.tables;
  wireless = config.martiert.networking.wireless;
  wifi_networks = import ../../secrets/wifi_networks.nix;

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
in {
  options = {
    martiert.networking = {
      wireless = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkEnableOption "wireless config";
            interfaces = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Interfaces to enable wireless for";
            };
          };
        };
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
    networking.wireless = {
      enable = wireless.enable;
      interfaces = wireless.interfaces;
      userControlled.enable = true;
      networks = wifi_networks;
    };

    networking.iproute2 = {
      enable = true;
      rttablesExtraConfig = concatStringsSep "\n" (mapAttrsToList createTableEntry tables) + "\n";
    };

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
