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
      ../machines/laptop.nix
    ];
    networking.hostName = "moghedien";
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
