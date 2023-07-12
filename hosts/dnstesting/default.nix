{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "dnstesting.martiert.com";

  nixos = ({modulesPath, pkgs, ...}: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      ./networking.nix
      ./blocking.nix
      ../../machines/nixos-cache.nix
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
      audio.enable = false;
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/aginor.pub
          ./public_keys/perrin.pub
        ];
      };
      zones."lencr.org" = {
        enable = true;
        records = {
          A = {
            "r3.o" = "138.68.145.241";
            "r3.i" = "138.68.145.241";
          };
        };
      };
    };
  });
}
