{ nixpkgs, ... }:

{
  system = "aarch64-linux";
  deployTo = "unifi";

  nixos = ({modulesPath, lib, pkgs, config, ...}: {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ];

    services.unifi = {
      enable = true;
      openFirewall = true;
      maximumJavaHeapSize = 256;
    };
    networking.firewall.enable = false;
    networking.firewall.allowedTCPPorts = [ 8443 ];
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unifi-controller"
      "mongodb"
    ];

    martiert = {
      system = {
        type = "server";
        aarch64 = {
          arch = "rpi3";
        };
      };
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/perrin.pub
          ./public_keys/schnappi.pub
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
