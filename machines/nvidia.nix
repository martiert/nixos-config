{ config, lib, ... }:

with lib;

let
  martiert = config.martiert;
  nvidiaPkgs = config.boot.kernelPackages.nvidiaPackages;
in mkIf (martiert.system.gpu == "nvidia") {
  hardware.nvidia = {
    package = nvidiaPkgs.beta;
    open = martiert.hardware.nvidia.openDriver;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
