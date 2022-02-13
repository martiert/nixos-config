{ nixpkgs, ... }:

{
  system = "aarch64-linux";

  nixos = ({modulesPath, ...}: {
    nixpkgs.overlays = [
      (import ./overlays/octoprint.nix)
    ];

    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../../machines/rpi3.nix
      ../../secrets/home_wireless.nix
      ../../nixos/services/openssh.nix
      ../../nixos/services/octoprint.nix
    ];

    networking.hostName = "octoprint";
  });

  home-manager = {};
}
