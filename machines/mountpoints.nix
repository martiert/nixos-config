{ config, lib, ... }:

with lib;

let
  cfg = config.martiert.mountpoints;
in {
  boot.initrd.luks = mkIf (cfg.root != null) {
    fido2Support = true;
    devices."root" = {
      fido2.credentials = cfg.root.credentials;
      device = cfg.root.encryptedDevice;
      preLVM = false;
      fallbackToPassword = true;
    };
  };
  fileSystems."/" = mkIf (cfg.root != null) {
    device = cfg.root.device;
    fsType = "ext4";
  };
  fileSystems."/boot" = mkIf (cfg.boot != null) {
    device = cfg.boot;
    fsType = "vfat";
  };

  swapDevices = mkIf (cfg.swap != null) [{
    device = cfg.swap;
    randomEncryption = true;
  }];
}
