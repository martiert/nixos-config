{ lib, ... }:

{
  networking = {
    usePredictableInterfaceNames = lib.mkForce false;
    dhcpcd.enable = false;

    nameservers = [ "8.8.8.8" ];
    defaultGateway = "46.101.80.1";
    defaultGateway6 = "2a03:b0c0:1:d0::1";

    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address = "46.101.88.168"; prefixLength = 20; }
        ];
        ipv6.addresses = [
          { address = "2a03:b0c0:1:d0::e65:8001"; prefixLength = 64; }
        ];
      };
      eth1 = {
        ipv4.addresses = [
          { address = "10.16.0.5"; prefixLength = 20; }
        ];
        ipv6.addresses = [
          { address = "fe80::7ceb:8eff:feb2:5f8c"; prefixLength = 64; }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="7e:eb:8e:b2:5f:8c", NAME="eth0"
    ATTR{address}=="b6:d5:d4:a5:1d:31", NAME="eth1"
  '';
}
