{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    openconnect-sso = {
      url = "github:vlaci/openconnect-sso";
      flake = false;
    };
    martiert = {
      url = "github:martiert/nix-overlay";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, openconnect-sso, martiert, ... }@inputs: {
    nixosConfigurations = {
      octoprint = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({modulesPath, ...}: {
            nixpkgs.overlays = [
              (import ./overlays/octoprint.nix)
            ];

            imports = [
              "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
              ./machines/rpi3.nix
              ./secrets/home_wireless.nix
              ./users/martin.nix
              ./users/root.nix
              ./services/openssh.nix
              ./services/octoprint.nix
              ./configs/timezone.nix
            ];

            networking.hostName = "octoprint";
          })
        ];
      };

      moghedien = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({modulesPath, ...}: {
            nixpkgs.overlays = [
              (import "${openconnect-sso}/overlay.nix")
              (import "${martiert}")
            ];

            imports = [
              ./machines/laptop.nix
            ];
            networking.hostName = "moghedien";
          })
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.martin = {
              imports = [
                ./home-manager/all.nix
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
          }
        ];
      };
    };
  };
}
