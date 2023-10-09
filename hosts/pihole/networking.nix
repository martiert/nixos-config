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
    ATTR{address}=="96:b3:f9:10:b1:91", NAME="eth0"
    ATTR{address}=="26:a4:3c:7c:ec:4f", NAME="eth1"
  '';
}
