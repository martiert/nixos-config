{ lib, ... }:

{
  networking = {
    usePredictableInterfaceNames = lib.mkForce false;

    nameservers = [ "8.8.8.8" ];

    interfaces = {
      eth0.useDHCP = true;
      eth1.useDHCP = true;
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="82:c2:92:e5:68:61", NAME="eth0"
    ATTR{address}=="32:4f:53:6f:34:b0", NAME="eth1"
  '';
}
