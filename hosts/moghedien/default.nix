{ nixpkgs
, openconnect-sso
, martiert
, cisco
, webex-linux
, vysor
, deploy-rs
, ...}:

let
  system = "x86_64-linux";
in {
  inherit system;
  nixos = ({modulesPath, ...}: {
    nixpkgs.overlays = [
      (import "${openconnect-sso}/overlay.nix")
      (import martiert)
      (self: super: {
        vysor = super.callPackage vysor {};
        teamctl = cisco.outputs.packages."${system}".teamctl;
        roomctl = cisco.outputs.packages."${system}".roomctl;
      })
    ];

    imports = [
      ../../machines/x86_64.nix
      ../../nixos/configs/common.nix
    ];
    networking.useDHCP = false;
    networking.resolvconf.enable = true;
    networking.dhcpcd.extraConfig = "resolv.conf";

    networking.interfaces.wlp1s0.useDHCP = true;

    networking.hostName = "moghedien";
    martiert = {
      mountpoints = {
        keyDisk.keyFile = "luks/moghedien.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/90041fed-c9a4-4139-a61d-76c6c4aca100";
          device = "/dev/disk/by-uuid/747150e3-46c0-41a2-8735-3c042dec1d2d";
        };
        boot = "/dev/disk/by-uuid/C414-3256";
        swap = "/dev/disk/by-partuuid/813b7f11-8581-4af9-839c-c46e0be03f39";
      };
      networking.wireless = {
        enable = true;
        interfaces = [ "wlp1s0" ];
      };
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
        deploy-rs.packages."${system}".deploy-rs
      ];

      martiert = {
        i3status = {
          enable = true;
          wireless = {
            wlp1s0 = 1;
          };
          battery = true;
        };
        i3 = {
          enable = true;
          barSize = 10.0;
        };
      };
    };
  };
}
