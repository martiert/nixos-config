{ lib, config,  ... }:

with lib;

let
  martiert = config.martiert;
in {
  options = {
    martiert.dnsproxy.enable = mkEnableOption "Proxy dns requests through a local dns server";
  };
  config = {
    services.dnsmasq = {
      enable = martiert.dnsproxy.enable;
      resolveLocalQueries = true;
      settings = {
        conf-file = config.age.secrets."dns_servers".path;
      };
    };
  };
}
