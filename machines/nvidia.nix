{ config, ... }:

{
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    open = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
