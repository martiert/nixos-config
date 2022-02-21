{ config, pkgs, lib, ... }:

with lib;

let
  bootCfg = config.martiert.boot;
  hardwareCfg = config.martiert.hardware;
in {
  options.martiert.boot = {
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

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

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
    ];

    hardware.enableRedistributableFirmware = true;
    powerManagement.cpuFreqGovernor = mkDefault "powersave";
    hardware.cpu.intel.updateMicrocode = mkDefault true;
    hardware.video.hidpi.enable = mkDefault hardwareCfg.hidpi.enable;

    services.udev.packages = [ pkgs.projecteur ];
  };
}
