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
    ATTR{address}=="7e:eb:8e:b2:5f:8c", NAME="eth0"
    ATTR{address}=="b6:d5:d4:a5:1d:31", NAME="eth1"
  '';
}
