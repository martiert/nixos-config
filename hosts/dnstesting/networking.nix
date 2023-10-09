{ lib, ... }:

{
  networking = {
    usePredictableInterfaceNames = lib.mkForce false;

    nameservers = [ "8.8.8.8" ];

    interfaces = {
      ens3.useDHCP = true;
      ens4.useDHCP = true;
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="02:89:6d:be:f5:ef", NAME="ens3"
    ATTR{address}=="da:81:57:1a:0c:cd", NAME="ens4"
  '';
}
