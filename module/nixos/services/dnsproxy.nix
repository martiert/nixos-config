{ config,  ... }:

let
  martiert = config.martiert;
in {
  services.dnsmasq = {
    enable = martiert.dnsproxy.enable;
    resolveLocalQueries = true;
    settings = {
      conf-file = config.age.secrets."dns_servers".path;
    };
  };
}
