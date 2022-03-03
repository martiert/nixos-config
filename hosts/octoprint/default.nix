{ nixpkgs, ... }:

let
  wifi_networks = import ../../secrets/wifi_networks.nix;
in {
  system = "aarch64-linux";
  deployTo = "octoprint.localdomain";

  nixos = ({modulesPath, config, ...}: {
    nixpkgs.overlays = [
      (import ./overlays/octoprint.nix)
    ];

    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ../../machines/rpi3.nix
      ../../nixos/services/openssh.nix
      ../../nixos/services/octoprint.nix
    ];

    networking.useDHCP = false;
    networking.interfaces.wlan0.useDHCP = true;
    age.secrets."wpa_supplicant".file = ../../secrets/wpa_supplicant_wireless.age;
    networking.supplicant = {
      "wlan0" = {
        configFile.path = config.age.secrets."wpa_supplicant".path;
        userControlled.enable = true;
        extraConf = ''
          ap_scan=1
          p2p_disabled=1
        '';
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
      networking.wireless = {
        enable = true;
        interfaces = [ "wlan0" ];
      };
    };
  });
}
