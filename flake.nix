{
  description = "images for creation";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-21.11";
  };

  outputs = { self, nixos, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      octoprint = nixos.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({modulesPath, pkgs, ...}: {
            imports = [
              "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
              ./machines/rpi3.nix
              ./secrets/home_wireless.nix
              ./users/martin.nix
              ./users/root.nix
              ./services/openssh.nix
            ];

            networking.hostName = "octoprint";
          })
        ];
      };
    };
  };
}
