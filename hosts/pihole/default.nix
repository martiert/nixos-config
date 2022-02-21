{ nixpkgs, ... }:

let
  wifi_networks = import ../../secrets/wifi_networks.nix;
in {
  system = "aarch64-linux";

  nixos = ({modulesPath, ...}: {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../../machines/rpi3.nix
      ../../nixos/services/openssh.nix
      ../../nixos/services/pihole.nix
    ];

    networking.useDHCP = false;
    networking.interfaces.wlan0.useDHCP = true;

    networking.hostName = "pihole2";
    martiert = {
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ../../public_keys/pihole/moghedien.pub
          ../../public_keys/pihole/moridin.pub
          ../../public_keys/pihole/perrin.pub
        ];
      };
      networking.wireless = {
        enable = true;
        interfaces = [ "wlan0" ];
      };
    };
  });

  home-manager = {};
}
