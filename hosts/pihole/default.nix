{ nixpkgs, ... }:

{
  system = "aarch64-linux";
  deployTo = "pihole.localdomain";

  nixos = ({modulesPath, ...}: {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../../machines/rpi3.nix
      ../../nixos/services/openssh.nix
      ../../nixos/services/pihole
    ];

    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    martiert = {
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/perrin.pub
        ];
      };
    };
  });
}
