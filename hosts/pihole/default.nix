{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "pihole.martiert.com";

  nixos = ({modulesPath, ...}: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      ./networking.nix
      ../../machines/nixos-cache.nix
      ../../settings/nixos/services/openssh.nix
      ../../settings/nixos/services/pihole
    ];

    boot = {
      loader.grub.device = "/dev/vda";
      initrd.kernelModules = [ "nvme" ];
      tmp.cleanOnBoot = true;
    };
    zramSwap.enable = true;

    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };

    martiert = {
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/perrin.pub
          ./public_keys/aginor.pub
          ./public_keys/schnappi.pub
        ];
      };
    };
  });
}
