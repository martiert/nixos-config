{ lib, ... }:

{
  networking = {
    usePredictableInterfaceNames = lib.mkForce false;
    dhcpcd.enable = false;

    nameservers = [ "8.8.8.8" ];
    defaultGateway = "139.59.160.1";

    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="139.59.160.195"; prefixLength=20; }
          { address="10.106.0.4"; prefixLength=16; }
        ];
        ipv4.routes = [ { address = "139.59.160.1"; prefixLength = 32; } ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:b3:f9:10:b1:91", NAME="eth0"
    ATTR{address}=="26:a4:3c:7c:ec:4f", NAME="eth1"
  '';
}
