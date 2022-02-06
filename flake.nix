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

      moghedien = import ./hosts/moghedien.nix {
        inherit nixpkgs home-manager openconnect-sso martiert;
      };
    };
  };
}
