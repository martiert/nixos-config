{ config,  ... }:

{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      conf-file = config.age.secrets."dns_servers".path;
    };
  };
}
