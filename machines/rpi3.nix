{
  boot = {
    kernelModules = [ "bcm2835-v4l2" ];
    loader.raspberryPi = {
      enable = true;
      version = 3;
      uboot.enable = true;
      firmwareConfig = ''
        start x=1
        gpu_mem=256
      '';
    };
  };
  hardware.enableRedistributableFirmware = true;
}
