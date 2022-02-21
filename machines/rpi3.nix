{
  boot = {
    kernelModules = [ "bcm2835-v4l2" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  hardware.enableRedistributableFirmware = true;
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "moridin.martiert.com:MpOYdKDwUz4u8UpSJGxGUR3Xj40RPJRIvDW9b0vUM6o="
  ];
}
