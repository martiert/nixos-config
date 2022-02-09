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
      ../machines/x86_64.nix
      ../users/martin.nix
      ../users/root.nix
      ../nixos/configs/common.nix
      ../secrets/moghedien_network.nix
    ];
    networking.hostName = "moghedien";
    martiert.mountpoints = {
      keyDisk.keyFile = "luks/moghedien.key";
      root = {
        encryptedDevice = "/dev/disk/by-uuid/90041fed-c9a4-4139-a61d-76c6c4aca100";
        device = "/dev/disk/by-uuid/747150e3-46c0-41a2-8735-3c042dec1d2d";
      };
      boot = "/dev/disk/by-uuid/C414-3256";
      swap = "/dev/disk/by-partuuid/813b7f11-8581-4af9-839c-c46e0be03f39";
    };
  });

  home-manager = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.martin = {
      imports = [
        ../home-manager/all.nix
      ];

      home.packages = [
        webex-linux.packages."${system}".webexWayland
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
