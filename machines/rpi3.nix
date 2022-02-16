{
  boot = {
    kernelModules = [ "bcm2835-v4l2" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  hardware.enableRedistributableFirmware = true;
}
