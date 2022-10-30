{ nixpkgs
, ...}:

rec {
  system = "x86_64-linux";
  nixos = ({ config, ... }: {
    imports = [
      ../../settings/nixos/configs/common.nix
      ../../settings/nixos/services/dnsproxy.nix
      ../../settings/nixos/users/martin.nix
      ../../settings/nixos/users/root.nix
      ../../settings/nixos/services/openssh.nix
      ../../machines/wsl.nix
    ];
    nix.settings.trusted-users = [
      "root"
      "martin"
    ];
    wsl = {
      enable = true;
      automountPath = "/mnt";
      defaultUser = "martin";
      startMenuLaunchers = false; # Done below to include Home Manager apps
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
      sshd.enable = true;
      networking.interfaces = {
        "eth0" = {
          enable = true;
          useDHCP = true;
        };
      };
    };

    home-manager.users.martin = {
      imports = [
        ../../settings/home-manager/all.nix
        ../../settings/home-manager/x86_64-linux.nix
      ];

      home.stateVersion = "22.05";
    };
  });
}
