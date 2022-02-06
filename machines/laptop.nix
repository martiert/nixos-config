{ lib, ... }:

let
  disk = "/dev/disk/by-label/keys";
  keyDir = "/keys";
in
{
  imports = [
    ./x86_64.nix
    ./mountpoints.nix
    ../users/martin.nix
    ../users/root.nix
    ../secrets/moghedien_network.nix
    ../configs/common.nix
  ];

  boot.initrd.availableKernelModules = [ "vfat" "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "uas" "usbcore" "usb_storage" "ext4" "nls_cp437" "nls_iso8859_1" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  martiert.mountpoints = {
    keyDisk.keyFile = "luks/moghedien.key";
    root = {
      encryptedDevice = "/dev/disk/by-uuid/90041fed-c9a4-4139-a61d-76c6c4aca100";
      device = "/dev/disk/by-uuid/747150e3-46c0-41a2-8735-3c042dec1d2d";
    };
    boot = "/dev/disk/by-uuid/C414-3256";
    swap = "/dev/disk/by-partuuid/813b7f11-8581-4af9-839c-c46e0be03f39";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
