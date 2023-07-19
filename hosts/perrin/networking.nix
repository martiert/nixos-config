{ config, ... }:

{
  martiert.networking = {
    dhcpcd.leaveResolveConf = true;
    interfaces = {
      "eno1" = {
        enable = true;
        useDHCP = true;
      };
      "enp6s0" = {
        enable = true;
        useDHCP = true;
        staticRoutes = true;
        supplicant = { config, ... }: {
          enable = true;
          wired = true;
          configFile = config.age.secrets.wpa_supplicant_enp6s0.path;
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
