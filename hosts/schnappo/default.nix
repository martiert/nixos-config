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
          encryptedDevice = "/dev/disk/by-uuid/5399de08-ea02-453f-870c-d9e901a04724";
          useFido2Device = true;
        };
        boot = "/dev/disk/by-uuid/A2EB-BCC6";
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
