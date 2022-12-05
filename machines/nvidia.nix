{ config, lib, ... }:

let
  cfg = config.martiert.hardware.nvidia;
  nvidiaPkgs = config.boot.kernelPackages.nvidiaPackages;
in {
  options.martiert.hardware.nvidia = {
    openDriver = lib.mkEnableOption "Enable using the open nvidia driver";
  };

  config = {
    hardware.nvidia = {
      package = nvidiaPkgs.beta;
      open = cfg.openDriver;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
