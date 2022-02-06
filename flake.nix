{
  description = "images for creation";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-21.11";
  };

  outputs = { self, nixos, ... }@inputs: {
    nixosConfigurations = {
      octoprint = nixos.lib.nixosSystem {
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

      moghedien = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({modulesPath, ...}: {
            imports = [
              ./machines/laptop.nix
              ./users/martin.nix
              ./users/root.nix
              ./secrets/moghedien_network.nix
              ./configs/common.nix
            ];
            networking.hostName = "moghedien";
          })
        ];
      };
    };
  };
}
