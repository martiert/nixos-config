{ nixpkgs, nixos-hardware, ... }:

{
  system = "aarch64-linux";
  hw_modules = [ nixos-hardware.nixosModules.pine64-pinebook-pro ];

  nixos = ({modulesPath, pkgs, config, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = [ "console=tty0" ];
    nixpkgs.config.allowUnfree = true;
    hardware = {
      deviceTree.enable = true;
      enableRedistributableFirmware = true;
    };
    services.upower.enable = true;
    martiert = {
      system = {
        type = "laptop";
      };
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/8f0d0007-42c0-4690-95e3-b0ae57bebd39";
          device = "/dev/mapper/root";
        };
        boot = "/dev/disk/by-uuid/FA77-0FEC";
      };
      boot.efi.removable = true;
      networking = {
        interfaces.wlan0 = {
          enable = true;
          useDHCP = true;
          supplicant = {
            enable = true;
            configFile = "/etc/wpa_supplicant.conf";
          };
        };
      };
      i3 = {
        enable = true;
      };
    };
  });
}

