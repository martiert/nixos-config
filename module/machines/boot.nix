{ pkgs, lib, config, ... }:

with lib;

let
  martiert = config.martiert;
in mkIf (builtins.elem martiert.system.type [ "desktop" "laptop" ]) {
  boot = {
    kernelPackages = mkDefault pkgs.linuxPackages_latest;
    kernelModules = martiert.boot.kernelModules;
    extraModulePackages = [ ];

    loader = {
      efi.canTouchEfiVariables = mkDefault (!martiert.boot.efi.removable);
      grub = {
        enable = mkDefault true;
        device = mkDefault "nodev";
        efiSupport = mkDefault true;
        efiInstallAsRemovable = mkDefault martiert.boot.efi.removable;
      };
    };
    initrd.kernelModules = martiert.boot.initrd.kernelModules;
  };
  hardware.enableRedistributableFirmware = mkDefault true;
}
