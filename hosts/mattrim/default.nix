{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "mattrim";

  nixos = ({ config, pkgs, ... }: {
    age.secrets."dropbear_key".file = ../../secrets/mattrim_dropbear_key.age;
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
        };
      };
      initrd = {
        secrets = {
          "/etc/dropbear/dropbear_key" = config.age.secrets."dropbear_key".path;
        };
        network = {
          udhcpc.enable = true;
          ssh = {
            enable = true;
            authorizedKeys = [
              ./public_keys/schnappi.pub
              ./public_keys/perrin.pub
            ];
            hostKeys = [
              "/etc/dropbear/dropbear_key"
            ];
          };
        };
      };
    };
    hardware.enableRedistributableFirmware = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    martiert = {
      system.type = "server";
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/76fe6c3a-1d87-4078-9cc0-c0dcba6b4be5";
          device = "/dev/mapper/root";
        };
        boot = "/dev/disk/by-uuid/98E4-83D6";
      };
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/schnappi.pub
          ./public_keys/perrin.pub
        ];
      };
      networking.interfaces.eno1 = {
        enable = true;
        useDHCP = true;
      };
    };
  });
}
