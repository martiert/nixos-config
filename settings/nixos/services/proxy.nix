{
  services.squid = {
    enable = true;
    proxyAddress = "0.0.0.0";
  };
  networking.firewall.allowedTCPPorts = [3128 53];
  networking.firewall.allowedUDPPorts = [3128 53];
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = "0.0.0.0";
        access-control = "0.0.0.0/0 allow";
        do-ip4 = true;
        do-udp = true;
      };
      access-control = "10.47.117.130/32 refuse";
      logfile = "/var/lib/unbound";
    };
  };
}
