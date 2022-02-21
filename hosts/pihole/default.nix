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
      ../../nixos/services/pihole
    ];

    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    networking.hostName = "pihole";

    martiert = {
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ../../public_keys/pihole/moghedien.pub
          ../../public_keys/pihole/moridin.pub
          ../../public_keys/pihole/perrin.pub
        ];
      };
    };
  });

  home-manager = {};
}
