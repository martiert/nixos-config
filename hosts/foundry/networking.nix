{ lib, ... }:

{
  networking = {
    usePredictableInterfaceNames = lib.mkForce false;
    dhcpcd.enable = false;

    nameservers = [ "8.8.8.8" ];
    defaultGateway = "178.128.160.1";
    defaultGateway6 = "2a03:b0c0:1:d0::1";

    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="178.128.168.3"; prefixLength=20; }
          { address="10.16.0.6"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="2a03:b0c0:1:d0::199:6001"; prefixLength=64; }
          { address="fe80::80c2:92ff:fee5:6861"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "178.128.160.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "2a03:b0c0:1:d0::1"; prefixLength = 128; } ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="82:c2:92:e5:68:61", NAME="eth0"
    ATTR{address}=="32:4f:53:6f:34:b0", NAME="eth1"
  '';
}
