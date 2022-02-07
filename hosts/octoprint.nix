{ nixpkgs, ... }:

{
  system = "aarch64-linux";

  nixos = ({modulesPath, ...}: {
    nixpkgs.overlays = [
      (import ../overlays/octoprint.nix)
    ];

    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../machines/rpi3.nix
      ../secrets/home_wireless.nix
      ../users/martin.nix
      ../users/root.nix
      ../services/openssh.nix
      ../services/octoprint.nix
    ];

    networking.hostName = "octoprint";
  });

  home-manager = {};
}
