{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "foundry.martiert.com";

  nixos = ({modulesPath, pkgs, ...}: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      ./networking.nix
      ./foundry.nix
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
      system.type = "server";
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/moridin.pub
          ./public_keys/aginor.pub
          ./public_keys/perrin.pub
          ./public_keys/schnappi.pub
        ];
      };
    };
  });
}
