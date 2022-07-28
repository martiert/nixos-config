{ pkgs, ... }:

{
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = [ "0.0.0.0" ];
        access-control = "0.0.0.0/0 allow";
      };
      include = "${pkgs.dns_blocklist}/unbound/unbound.blacklist.conf";
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "208.67.222.222"
            "208.67.220.220"
          ];
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
