{ nixpkgs
, openconnect-sso
, martiert
, cisco
, webex-linux
, vysor
, ...}:

let
  system = "x86_64-linux";
in {
  inherit system;
  nixos = ({modulesPath, ...}: {
    nixpkgs.overlays = [
      (import "${openconnect-sso}/overlay.nix")
      (import martiert)
      (import cisco)
      (self: super: {
        vysor = super.callPackage vysor {};
      })
    ];

    imports = [
      ../../machines/x86_64.nix
      ../../nixos/configs/common.nix
      ../../nixos/services/openssh.nix
      ../../secrets/moridin_networking.nix
    ];
    networking.hostName = "moridin";
    martiert = {
      mountpoints = {
        keyDisk.keyFile = "luks/moridin.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/4ea0a56f-90d0-48ad-a5f2-80befab4b826";
          device = "/dev/disk/by-label/nixos";
        };
        boot = "/dev/disk/by-label/boot";
        swap = "/dev/disk/by-partuuid/54830ffa-cb0b-4a6f-b79b-ab162f4bd009";
      };
      boot.initrd.extraAvailableKernelModules = [ "usbhid" "rtsx_pci_sdmmc" ];
      hardware.hidpi.enable = true;
      services.xserver = {
        defaultSession = "none+i3";
      };
      sshd.enable = true;
    };
  });

  home-manager = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.martin = {
      imports = [
        ../../home-manager/all.nix
      ];

      home.packages = [
        webex-linux.packages."${system}".webexWayland
      ];

      martiert = {
        i3status = {
          enable = true;
          ethernet = {
            eno1 = 2;
            enp0s20f0u3 = 3;
          };
        };
        i3 = {
          enable = true;
        };
        email.enable = true;
        irssi.enable = true;
      };
    };
  };
}
