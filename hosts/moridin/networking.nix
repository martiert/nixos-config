{ config, ... }:

let
  secrets = config.age.secrets;
in {
  martiert.networking = {
    dhcpcd.leaveResolveConf = true;
    interfaces = {
      "eno1" = {
        enable = true;
        useDHCP = true;
      };
      "enp0s20f0u3" = {
        enable = true;
        useDHCP = true;
        staticRoutes = true;
        supplicant = { config, ... }: {
          enable = true;
          wired = true;
          configFile = secrets.wpa_supplicant_enp0s20f0u3.path;
        };
      };
    };
    tables = {
      cisco = {
        number = 42;
        enable = true;
        rules = [
          {
            from = "192.168.1.1/24";
          }
        ];
        routes = {
          default = {
            value = "via 192.168.1.1";
          };
        };
      };
    };
  };
}
