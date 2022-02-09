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
}
