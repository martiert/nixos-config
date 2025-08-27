{ nixpkgs
, ...}:

let
  system = "aarch64-linux";
in {
  inherit system;
  nixos = ({ pkgs, config, ... }: {
    imports = [
      ./hardware.nix
    ];
    nix.settings.trusted-users = [
      "root"
      "martin"
    ];
    networking = {
      useDHCP = false;
      resolvconf.enable = true;
      dhcpcd.extraConfig = "resolv.conf";
    };
    services.rsyslogd.enable = true;

    martiert = {
      system = {
        type = "laptop";
      };
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/adaa729e-530b-4cc8-9519-572e8178de16";
          useFido2Device = true;
        };
        boot = "/dev/disk-by-uuid/F170-623B";
      };
      sshd.enable = true;
      networking = {
        interfaces = {
          "wlP4p1s0" = {
            enable = true;
            supplicant = {
              enable = true;
            };
            useDHCP = true;
          };
        };
      };
      i3 = {
        enable = true;
      };
    };
  });
}
