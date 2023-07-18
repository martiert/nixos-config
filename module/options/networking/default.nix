{ lib, config, ... }:

with lib;

{
  options = {
    martiert.networking = {
      interfaces = mkOption {
        default = {};
        description = "Config for network interface";
        type = types.attrsOf (types.submodule {
          options = {
            enable = mkEnableOption "interface";
            useDHCP = mkEnableOption "dhcp for this interface";
            bridgedInterfaces = mkOption {
              default = [];
              type = types.listOf types.string;
              description = "Interfaces to add to the bridge";
            };
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
      dhcpcd = mkOption {
        default = {};
        description = "Configurations for dhcp";
        type = types.submodule {
          options = {
            leaveResolveConf = mkEnableOption "turning off messing with resolve conf";
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
}
