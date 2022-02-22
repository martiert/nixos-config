{ config, lib, ... }:

with lib;

let
  cfg = config.martiert.mountpoints;
  keyDir = "/keys";
in {
  options.martiert.mountpoints = {
    keyDisk = mkOption {
      type = types.submodule {
        options = {
          disk = mkOption {
            type = types.str;
            default = "/dev/disk/by-label/keys";
            description = "disk to mount for luks decryption";
          };
          keyFile = mkOption {
            type = types.str;
            description = "keyfile to use";
          };
        };
      };
    };
    root = mkOption {
      type = types.submodule {
        options = {
          encryptedDevice = mkOption {
            type = types.str;
            description = "device to unlock";
          };
          device = mkOption {
            type = types.str;
            description = "decrypted device to mount";
          };
        };
      };
    };
    boot = mkOption {
      type = types.str;
      description = "device to mount to /boot";
    };
    swap = mkOption {
      type = types.nullOr types.str;
      description = "swap device to mount";
      default = null;
    };
  };

  config = {
    boot.initrd.luks.devices."root" = {
      device = cfg.root.encryptedDevice;
      keyFile = "${keyDir}/${cfg.keyDisk.keyFile}";
      preLVM = false;
      fallbackToPassword = true;
      preOpenCommands = ''
        mkdir "${keyDir}"
        waitDevice "${cfg.keyDisk.disk}"
        mount "${cfg.keyDisk.disk}" "${keyDir}"
      '';
    };
    fileSystems."/" = {
      device = cfg.root.device;
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = cfg.boot;
      fsType = "vfat";
    };
    swapDevices = mkIf (cfg.swap != null) [{
      device = cfg.swap;
      randomEncryption = true;
    }];
  };
}
