{ pkgs, ... }:

{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      domain-needed
      bogus-priv
      no-resolv

      local=/local/
      domain=local
      expand-hosts

      cache-size=10000
      log-queries
      log-facility=/tmp/ad-block.log
      local-ttl=300

      conf-file=${pkgs.dns_blocklist}/dnsmasq/dnsmasq.blacklist.txt
    '';
    servers = [
      "208.67.222.222"
      "208.67.220.220"
    ];
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
