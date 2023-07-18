{ lib, config, ... }:

let
  martiert = config.martiert;
in lib.mkIf (martiert.system.aarch64.arch == "rpi3") {
  boot = {
    kernelModules = [ "bcm2835-v4l2" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  hardware.enableRedistributableFirmware = true;
}
