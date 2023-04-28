{ config, pkgs, lib, ... }:

with lib;

let
  bootCfg = config.martiert.boot;
  hardwareCfg = config.martiert.hardware;
in {
  options.martiert.boot = {
    efi.removable = mkOption {
      type = types.bool;
      default = false;
      description = "Install boot loader as removable";
    };
    initrd = mkOption {
      type = types.submodule {
        options = {
          extraAvailableKernelModules = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Extra kernel module to make available";
          };
        };
      };
      default = {
        extraAvailableKernelModules = [];
      };
    };
    kernelModules = mkOption {
      type = types.listOf types.str;
      default = [ "kvm-intel" ];
      description = "Default kernel modules";
    };
  };
  options.martiert.hardware.hidpi = {
    enable = mkEnableOption "enable hidpi mode";
  };
  imports = [
    ./mountpoints.nix
    ./allowedPackages.nix
  ];

  config = {
    boot.initrd.availableKernelModules = [
      "vfat"
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ] ++ bootCfg.initrd.extraAvailableKernelModules;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.initrd.kernelModules = [ "uas" "usbcore" "usb_storage" "ext4" "nls_cp437" "nls_iso8859_1" ];
    boot.kernelModules = bootCfg.kernelModules;
    boot.extraModulePackages = [ ];

    boot.tmp.useTmpfs = true;

    boot.loader = {
      efi.canTouchEfiVariables = !bootCfg.efi.removable;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = bootCfg.efi.removable;
        version = 2;
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
  };
}
