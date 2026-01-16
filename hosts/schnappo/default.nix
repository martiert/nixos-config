{ nixpkgs
, ...}:

let
  system = "aarch64-linux";
in {
  inherit system;
  nixos = ({ pkgs, lib, config, ... }: {
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
    services.upower.enable = true;
    boot.initrd.systemd.tpm2.enable = false;
    systemd.tpm2.enable = false;

    age.secrets."wpa_supplicant_wlP4p1s0".file = ../../secrets/wpa_supplicant_wireless.age;
    martiert = {
      system = {
        type = "laptop";
      };
      services.waylandOnly = true;
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/5399de08-ea02-453f-870c-d9e901a04724";
          # useFido2Device = true;
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
              configFile = config.age.secrets.wpa_supplicant_wlP4p1s0.path;
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
