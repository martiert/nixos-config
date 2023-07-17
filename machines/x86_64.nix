{ config, pkgs, lib, ... }:

with lib;

let
  martiert = config.martiert;
in mkIf (pkgs.system == "x86_64-linux" && builtins.elem martiert.system.type [ "desktop" "laptop" ]) {
  boot.initrd.availableKernelModules = [
    "vfat"
    "xhci_pci"
    "ahci"
    "nvme"

    "usb_storage"
    "sd_mod"
  ] ++ martiert.boot.initrd.extraAvailableKernelModules;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.kernelModules = [ "uas" "usbcore" "usb_storage" "ext4" "nls_cp437" "nls_iso8859_1" ];
  boot.kernelModules = martiert.boot.kernelModules;
  boot.extraModulePackages = [ ];

  boot.tmp.useTmpfs = true;

  boot.loader = {
    efi.canTouchEfiVariables = !martiert.boot.efi.removable;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = martiert.boot.efi.removable;
    };
  };

  services.pcscd.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.enableRedistributableFirmware = true;
  powerManagement.cpuFreqGovernor = mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = mkDefault true;

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "userns-remap" = "default";
    };
  };

  users.groups.dockremap.gid = 10000;

  users.users = {
    dockremap = {
      isSystemUser = true;
      uid = 10000;
      group = "dockremap";
      subUidRanges = [
        {
          startUid = 1000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100;
          count = 65536;
        }
      ];
    };
  };

  services.udev.packages = [ pkgs.projecteur ];

  nix.settings.trusted-users = [
    "root"
    "martin"
  ];

  programs.adb.enable = true;
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 20000;
      to = 65535;
    }
  ];
}
