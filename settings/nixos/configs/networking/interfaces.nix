{ lib, config, ...}:

let
  interfaces = config.martiert.networking.interfaces;
  enabled_interfaces = lib.filterAttrs (_: value: value.enable) interfaces;

  supplicantConfig = iface: values: {
    configFile.path = config.age.secrets."wpa_supplicant_${iface}".path;
    userControlled.enable = !values.supplicant.wired;
    extraConf = if values.supplicant.wired then "" else ''
      ap_scan=1
      p2p_disabled=1
    '';
    driver = if values.supplicant.wired then "wired" else "nl80211,wext";
  };
  supplicant_interfaces = lib.filterAttrs (_: value: value.supplicant.enable) enabled_interfaces;
  supplicant_config = builtins.mapAttrs supplicantConfig supplicant_interfaces;

  ifaceConfig = iface: value: {
    useDHCP = if (builtins.hasAttr "useDHCP" value) then value.useDHCP else false;
    ipv4.routes = lib.mkIf value.staticRoutes [
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
      { address = "12.19.88.90";      prefixLength = 32;  }
    ];
    ipv6.routes = lib.mkIf value.staticRoutes [
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

  disableDHCPGatewayFor = iface: _: ''
    interface ${iface}
    nogateway'';
  static_routed_interfaces = lib.filterAttrs (_: value: value.staticRoutes) enabled_interfaces;
  disabledDHCPGateways = lib.concatStrings (lib.mapAttrsToList disableDHCPGatewayFor static_routed_interfaces);

  globalDHCPConfig = if config.martiert.networking.dhcpcd.leaveResolveConf then
    "nohook resolv.conf" else "";

  extraDHCPConfig = lib.concatStringsSep "\n" [
    globalDHCPConfig
    disabledDHCPGateways
  ];

  makeBridge = _: value: {
    interfaces = value.bridgedInterfaces;
  };
  bridgeConfig = builtins.mapAttrs makeBridge (lib.filterAttrs (_: value: value.bridgedInterfaces != []) enabled_interfaces);
in {
  options = with lib; {
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
            unmanaged = mkEnableOption "unmanaged interface";
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
    };
  };
  config = {
    networking.useDHCP = false;
    networking.interfaces = interface_config;
    networking.supplicant = supplicant_config;

    networking.dhcpcd.extraConfig = extraDHCPConfig;
    networking.bridges = bridgeConfig;
  };
}
