{ nixpkgs, ... }:

{
  system = "aarch64-linux";

  nixos = ({modulesPath, ...}: {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../machines/rpi3.nix
      ../secrets/home_wireless.nix
      ../nixos/services/openssh.nix
      ../nixos/services/pihole.nix
    ];

    networking.hostName = "pihole2";
  });

  home-manager = {};
}
