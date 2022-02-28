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

    boot.initrd.kernelModules = [ "uas" "usbcore" "usb_storage" "ext4" "nls_cp437" "nls_iso8859_1" ];
    boot.kernelModules = bootCfg.kernelModules;
    boot.extraModulePackages = [ ];

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

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "cnijfilter2"
      "google-chrome"
      "skypeforlinux"
      "steam"
      "steam-original"
      "steam-runtime"
      "webex-linux"
      "teamctl"
      "roomctl"
      "Oracle_VM_VirtualBox_Extension_Pack"
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
    ];

    hardware.enableRedistributableFirmware = true;
    powerManagement.cpuFreqGovernor = mkDefault "powersave";
    hardware.cpu.intel.updateMicrocode = mkDefault true;
    hardware.video.hidpi.enable = mkDefault hardwareCfg.hidpi.enable;

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
            startUid = 10000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 10000;
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
  };
}
