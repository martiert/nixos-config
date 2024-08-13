{ nixpkgs, nixos-hardware, ... }:

{
  system = "aarch64-linux";
  deployTo = "hydra-rpi-builder";

  hw_modules = [ nixos-hardware.nixosModules.raspberry-pi-5 ];

  nixos = ({modulesPath, pkgs, config, ... }: {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ];

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    martiert = {
      system = {
        type = "server";
        aarch64 = {
          arch = "rpi5";
        };
      };
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/schnappi.pub
          ./public_keys/perrin.pub
          ./public_keys/hydra.pub
        ];
      };
      networking.interfaces = {
        "eth0" = {
          enable = true;
          useDHCP = true;
        };
      };
    };
  });
}
