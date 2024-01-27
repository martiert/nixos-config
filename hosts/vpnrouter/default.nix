{ nixpkgs, nixos-hardware, ... }:

{
  system = "aarch64-linux";
  deployTo = "vpnrouter";

  hw_modules = [ nixos-hardware.nixosModules.raspberry-pi-4 ];

  nixos = ({modulesPath, pkgs, config, ... }: {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ];

    hardware.raspberry-pi."4" = {
      poe-plus-hat.enable = true;
    };

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    services.hostapd = {
      enable = true;
      radios.wlan0 = {
        countryCode = "NO";
        band = "5g";
        channel = 0;
        networks.wlan0 = {
          ssid = "test";
          authentication = {
            saePasswords = [
              {
                password = "some test password":
              }
            ];
          }:
        };
      };
    };

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
