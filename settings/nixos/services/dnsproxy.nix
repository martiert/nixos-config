{ config, pkgs, lib, ... }:

with lib;

let
  interfaces = config.martiert.networking.interfaces;
  unmanaged_interfaces = lib.filterAttrs (_: value: value.enable && value.unmanaged) interfaces;
  unmanaged = builtins.attrNames unmanaged_interfaces;
in {
  config = {
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = true;
      extraConfig = ''
        conf-file = ${config.age.secrets."dns_servers".path}
      '';
    };
    networking.networkmanager = {
      enable = true;
      unmanaged = unmanaged;
      dns = "dnsmasq";
      dhcp = "dhcpcd";
    };
  };
}
