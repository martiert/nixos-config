{ lib, ... }:

let
  disk = "/dev/disk/by-label/keys";
  keyDir = "/keys";
in
{
  imports = [
    ./x86_64.nix
  ];

  boot.initrd.availableKernelModules = [ "vfat" "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "uas" "usbcore" "usb_storage" "ext4" "nls_cp437" "nls_iso8859_1" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/747150e3-46c0-41a2-8735-3c042dec1d2d";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/90041fed-c9a4-4139-a61d-76c6c4aca100";
    keyFile = "${keyDir}/luks/moghedien.key";
    preLVM = false;
    fallbackToPassword = true;
    preOpenCommands = ''
      mkdir "${keyDir}"
      waitDevice "${disk}"
      mount "${disk}" "${keyDir}"
    '';
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C414-3256";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/813b7f11-8581-4af9-839c-c46e0be03f39";
      randomEncryption = true;
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
