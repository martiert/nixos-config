{ pkgs, ... }:

let
  blocklist_dir = "/etc/nixos/assets/hosts-blocklists";
  domain_file = "${blocklist_dir}/domains.txt";
  domain_list_url = "https://github.com/notracking/hosts-blocklists/raw/master/dnsmasq/dnsmasq.blacklist.txt";
  download_file = pkgs.writeShellScriptBin "downloadDomains" ''
    ${pkgs.curl}/bin/curl --location ${domain_list_url} > ${domain_file}
  '';
in {
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

      address=/pi.hole/192.168.1.224

      conf-file=${domain_file}
    '';
    servers = [
      "192.168.1.1"
    ];
  };

  environment.etc."nixos/assets/hosts-blocklists/domains.txt" = {
    source = ./initial_blocklist;
    mode = "0600";
  };

  systemd.services.fetchDomains = {
    description = "Fetching domain file";

    preStart = "${pkgs.coreutils}/bin/mkdir --parent ${blocklist_dir}";
    postStart = "${pkgs.systemd}/bin/systemctl restart dnsmasq";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${download_file}/bin/downloadDomains";
    };
  };

  systemd.timers.fetchDomains = {
    description = "Fetching domain file";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      Persistent = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
