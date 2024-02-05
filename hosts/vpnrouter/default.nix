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

    networking.nftables = {
      enable = true;
      tables.nat = {
        enable = true;
        family = "ip";
        content = ''
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "eth0" masquerade
          }
        '';
      };
    };
    networking.firewall = {
      filterForward = true;
      extraForwardRules = ''
        iifname { "wlan0" } oifname { "eth0" } accept comment "Allow LAN to WAN"
        iifname { "eth0" } oifname { "wlan0" } ct state established, related accept comment "Allow established trafic back to LAN"
      '';
      interfaces.wlan0 = {
        allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
        allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
      };
    };
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };
    networking.interfaces.wlan0 = {
      ipv4.addresses = [{
        address = "10.8.8.1";
        prefixLength = 24;
      }];
    };
    services.hostapd = {
      enable = true;
      radios.wlan0 = {
        countryCode = "NO";
        channel = 48;
        band = "5g";
        networks.wlan0 = {
          ssid = "martiert testing";
          authentication.mode = "none";
        };
      };
    };
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        dhcp-range = [ "10.8.8.1,10.8.8.20,24h" ];
        interface = "wlan0";
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
          ./public_keys/perrin.pub
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
