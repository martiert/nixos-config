{ nixpkgs, nixos-hardware, ... }:

{
  system = "aarch64-linux";
  hw_modules = [ nixos-hardware.nixosModules.pine64-pinebook-pro ];

  nixos = ({ pkgs, config, ... }: {
    imports = [
      ./kernel
    ];

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = [ "console=tty0" ];

    nixpkgs.config.allowUnfree = true;
    hardware = {
      deviceTree.enable = true;
      enableRedistributableFirmware = true;
    };
    services.upower.enable = true;
    age = {
      identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets."wpa_supplicant_wlan0".file = ../../secrets/wpa_supplicant_wireless.age;
    };

    martiert = {
      system = {
        type = "laptop";
      };
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/8f0d0007-42c0-4690-95e3-b0ae57bebd39";
        };
        boot = "/dev/disk/by-uuid/FA77-0FEC";
      };
      terminal.default = "foot";
      boot.efi.removable = true;
      networking = {
        interfaces.wlan0 = {
          enable = true;
          useDHCP = true;
          supplicant = {
            enable = true;
            configFile = config.age.secrets."wpa_supplicant_wlan0".path;
          };
        };
      };
      i3 = {
        enable = true;
      };
    };
  });
}

