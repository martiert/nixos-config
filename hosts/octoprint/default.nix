{ nixpkgs, ... }:

{
  system = "aarch64-linux";
  deployTo = "octoprint.localdomain";

  nixos = ({modulesPath, pkgs, config, ...}: {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ./octoprint
    ];

    age.secrets."wpa_supplicant_wlan0".file = ../../secrets/wpa_supplicant_wireless.age;
    networking.firewall.allowedTCPPorts = [ 3001 ];

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
        "wlan0" = {
          enable = true;
          supplicant = {
            enable = true;
            configFile = config.age.secrets.wpa_supplicant_wlan0.path;
          };
          useDHCP = true;
        };
      };
    };
  });
}
