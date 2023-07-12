{ config, lib, ... }:

with lib;

let
  cfg = config.martiert.mountpoints;
  keyDir = "/keys";
in {
  options.martiert.mountpoints = {
    root = mkOption {
      default = null;
      type = types.nullOr (types.submodule {
        options = {
          encryptedDevice = mkOption {
            type = types.str;
            description = "device to unlock";
          };
          device = mkOption {
            type = types.str;
            description = "decrypted device to mount";
          };
          credentials = mkOption {
            type = types.listOf (types.str);
            description = "credentials for luks decryption";
            default = [];
          };
        };
      });
    };
    boot = mkOption {
      type = types.nullOr types.str;
      description = "device to mount to /boot";
      default = null;
    };
    swap = mkOption {
      type = types.nullOr types.str;
      description = "swap device to mount";
      default = null;
    };
  };

  config = {
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
  };
}
