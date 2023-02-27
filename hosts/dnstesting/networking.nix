{ lib, ... }:

{
  networking = {
    usePredictableInterfaceNames = lib.mkForce false;
    dhcpcd.enable = false;

    nameservers = [ "8.8.8.8" ];
    defaultGateway = "138.68.145.1";
    # defaultGateway6 = "2a03:b0c0:1:d0::1";

    interfaces = {
      ens3 = {
        ipv4.addresses = [
          { address = "138.68.145.241"; prefixLength = 20; }
        ];
      };
      ens4 = {
        ipv4.addresses = [
          { address = "10.106.0.5"; prefixLength = 20; }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="02:89:6d:be:f5:ef", NAME="ens3"
    ATTR{address}=="da:81:57:1a:0c:cd", NAME="ens4"
  '';
}
