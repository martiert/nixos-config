{ config,  ... }:

{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    extraConfig = ''
      conf-file = ${config.age.secrets."dns_servers".path}
    '';
  };
}
