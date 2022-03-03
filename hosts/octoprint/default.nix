{ nixpkgs, ... }:

{
  system = "aarch64-linux";
  deployTo = "octoprint.localdomain";

  nixos = ({modulesPath, config, ...}: {
    nixpkgs.overlays = [
      (import ./overlays/octoprint.nix)
    ];

    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../../machines/rpi3.nix
      ../../nixos/services/openssh.nix
      ../../nixos/services/octoprint.nix
    ];

    age.secrets."wpa_supplicant_wlan0".file = ../../secrets/wpa_supplicant_wireless.age;

    martiert = {
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/perrin.pub
        ];
      };
      networking.interfaces = {
        "wlan0" = {
          enable = true;
          supplicant = {
            enable = true;
          };
          useDHCP = true;
        };
      };
    };
  });
}
