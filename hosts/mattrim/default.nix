{ nixpkgs
, openconnect-sso
, ...}:

rec {
  system = "x86_64-linux";
  nixos = ({ config, ... }: {
    imports = [
      ../../settings/nixos/configs/common.nix
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
    };

    # Ensure /tmp/.X11-unix isn't cleaned by systemd-tmpfiles:
    # https://github.com/nix-community/NixOS-WSL/issues/114
    systemd.tmpfiles.rules = [
      "d /tmp/.X11-unix 1777 root root"
    ];
    networking.useDHCP = false;
    networking.resolvconf.enable = true;
    networking.dhcpcd.extraConfig = "resolv.conf";

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25591_key" ];

    martiert = {
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
      ];

      home.stateVersion = "22.05";
    };
  });
}
