{ nixpkgs, ... }:

let
  wifi_networks = import ../../secrets/wifi_networks.nix;
in {
  system = "aarch64-linux";

  nixos = ({modulesPath, ...}: {
    nixpkgs.overlays = [
      (import ./overlays/octoprint.nix)
    ];

    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../../machines/rpi3.nix
      ../../nixos/services/openssh.nix
      ../../nixos/services/octoprint.nix
    ];

    networking.useDHCP = false;
    networking.interfaces.wlan0.useDHCP = true;
    martiert = {
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ../../public_keys/octoprint/moghedien.pub
          ../../public_keys/octoprint/moridin.pub
          ../../public_keys/octoprint/perrin.pub
        ];
      };
      networking.wireless = {
        enable = true;
        interfaces = [ "wlan0" ];
      };
    };

    networking.hostName = "octoprint";
  });

  home-manager = {};
}
