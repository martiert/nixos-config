{ nixpkgs, ... }:

{
  system = "aarch64-linux";
  deployTo = "octoprint.localdomain";

  nixos = ({modulesPath, pkgs, config, ...}: {
    nixpkgs.overlays = [
      (import ./overlays/octoprint.nix)
    ];

    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../../machines/rpi3.nix
      ../../settings/nixos/services/openssh.nix
      ../../settings/nixos/services/octoprint.nix
    ];

    age.secrets."wpa_supplicant_wlan0".file = ../../secrets/wpa_supplicant_wireless.age;
    systemd.services.bedlevel = {
      enable = true;
      description = "bedlevel";
      after = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.bedlevel}/bin/bedlevel";
      };
    };

    martiert = {
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/perrin.pub
        ];
      };
      networking.interfaces = {
        "wlan0" = {
          enable = true;
          supplicant = {
            enable = true;
          };
          useDHCP = true;
        };
      };
    };
  });
}
