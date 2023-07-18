{ nixpkgs
, ...}:

rec {
  system = "x86_64-linux";
  nixos = ({ config, ... }: {
    nix.settings.trusted-users = [
      "root"
      "martin"
    ];
    wsl = {
      wslConf.network = {
        generateResolvConf = false;
        hostname = "mattrim";
      };
    };

    # Ensure /tmp/.X11-unix isn't cleaned by systemd-tmpfiles:
    # https://github.com/nix-community/NixOS-WSL/issues/114
    systemd.tmpfiles.rules = [
      "d /tmp/.X11-unix 1777 root root"
    ];
    networking = {
      useDHCP = false;
      resolvconf.enable = true;
      dhcpcd.extraConfig = "resolv.conf";
    };

    environment.etc."resolv.conf".source = "/etc/resolv.conf.conf";
    age.secrets."dns_servers".file = ../../secrets/dns_servers.age;

    martiert = {
      system.type = "wsl";
      dnsproxy.enable = true;
      sshd.enable = true;
      networking.interfaces = {
        "eth0" = {
          enable = true;
          useDHCP = true;
        };
      };
    };
  });
}
