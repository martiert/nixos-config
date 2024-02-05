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
            oifname "tun0" masquerade
          }
        '';
      };
    };
    networking.firewall = {
      filterForward = true;
      extraForwardRules = ''
        iifname { "wlan0" } oifname { "eth0" } accept comment "Allow LAN to WAN"
        iifname { "eth0" } oifname { "wlan0" } ct state established, related accept comment "Allow established trafic back to LAN"
        iifname { "wlan0" } oifname { "tun0" } accept comment "Allow LAN to WAN"
        iifname { "tun0" } oifname { "wlan0" } ct state established, related accept comment "Allow established trafic back to LAN"

      '';
      interfaces.wlan0 = {
        allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
        allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
      };
    };
    environment.etc = {
      "nordvpn/us.ovpn".source = ./nordvpn/us9804.nordvpn.com.udp.ovpn;
      "nordvpn/uk.ovpn".source = ./nordvpn/uk2382.nordvpn.com.udp.ovpn;
      "nordvpn/japan.ovpn".source = ./nordvpn/jp694.nordvpn.com.udp.ovpn;
      "nordvpn/australia.ovpn".source = ./nordvpn/au651.nordvpn.com.udp.ovpn;
      "nordvpn/germany.ovpn".source = ./nordvpn/de1100.nordvpn.com.udp.ovpn;
      "nordvpn/norway.ovpn".source = ./nordvpn/no231.nordvpn.com.udp.ovpn;
    };
    age.secrets = {
      vpn_passphrase.file = ../../secrets/vpn_passphrase.age;
      nordvpn_credentials.file = ../../secrets/nordvpn_credentials.age;
    };
    services.openvpn.servers.nordvpn = {
      updateResolvConf = true;
      config = ''
        config /etc/nordvpn/active.ovpn
        auth-user-pass ${config.age.secrets."nordvpn_credentials".path}
      '';
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
          ssid = "vpnrouter";
          authentication = {
            mode = "none";
            wpaPasswordFile = config.age.secrets."vpn_passphrase".path;
          };
          settings = {
            wpa = 2;
            wpa_pairwise = "CCMP";
            wpa_key_mgmt = "WPA-PSK";
          };
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
