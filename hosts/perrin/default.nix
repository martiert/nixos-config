{ nixpkgs
, openconnect-sso
, webex-linux
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = {
    startup = [
      { command = "alacritty"; }
      { command = "firefox"; }
      { command = "CiscoCollabHost"; }
      { command = "gimp"; }
    ];
    assigns = {
      "2" = [{ class = "^Firefox$"; }];
      "3" = [{ class = "^webex$"; }];
      "10" = [{ class = "^Gimp$"; }];
    };
  };
in {
  inherit system;
  nixos = {
    nixpkgs.overlays = [
      (import "${openconnect-sso}/overlay.nix")
    ];

    imports = [
      ../../machines/x86_64.nix
      ../../settings/nixos/configs/common.nix
      ../../settings/nixos/services/openssh.nix
      ../../settings/nixos/services/nginx.nix
    ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    services.xserver = {
      videoDrivers = [ "nvidia" ];
    };

    services.dnsmasq = 
      let
        dnsServers = import ../../secrets/dns_servers.nix;
      in {
        enable = true;
        resolveLocalQueries = true;
        servers = dnsServers.home ++ dnsServers.cisco;
      };

      networking.networkmanager = {
        enable = true;
        unmanaged = [ "enp4s0" ];
        dns = "dnsmasq";
        dhcp = "dhcpcd";
      };

    age.secrets."wpa_supplicant_enp4s0".file = ../../secrets/wpa_supplicant_wired.age;

    fileSystems."/home/martin/Cisco" = {
      device = "/dev/disk/by-uuid/e2e37fd7-4a01-4386-90e0-20ea8f37fc64";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/865caa0b-41fe-4517-a429-63a5a8972328";
        keyFile = "/mnt-root/etc/keys/cisco.key";
        label = "cisco";
      };
    };

    martiert = {
      mountpoints = {
        keyDisk.keyFile = "luks/perrin.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/34185190-271f-464b-91aa-d6707835ab60";
          device = "/dev/disk/by-uuid/29a4d0df-3ec4-4b32-914a-9329d4b18c99";
        };
        boot = "/dev/disk/by-uuid/34F2-B158";
        swap = "/dev/disk/by-partuuid/1bc95ed3-d38e-d64e-9410-43067e6cd4d5";
      };
      boot = {
        initrd.extraAvailableKernelModules = [ "usbhid" ];
        efi.removable = true;
      };
      hardware.hidpi.enable = true;
      services.xserver = {
        defaultSession = "none+i3";
      };
      networking = {
        dhcpcd.leaveResolveConf = true;
        interfaces = {
          "eno1" = {
            enable = true;
            useDHCP = true;
          };
          "enp4s0" = {
            enable = true;
            useDHCP = true;
            staticRoutes = true;
            supplicant = {
              enable = true;
              wired = true;
            };
          };
        };
        tables = {
          cisco = {
            number = 42;
            enable = true;
            rules = [
              {
                from = "192.168.1.1/24";
              }
            ];
            routes = {
              default = {
                value = "via 192.168.1.1";
              };
            };
          };
        };
      };
      sshd.enable = true;
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.martin = {
      imports = [
        ../../settings/home-manager/all.nix
      ];

      home.packages = [
        webex-linux.packages."${system}".webexWayland
      ];

      xsession.windowManager.i3.config = swayi3Config;
      martiert = {
        alacritty.fontSize = 14;
        i3status = {
          enable = true;
          ethernet = {
            eno1 = 2;
            enp4s0 = 3;
          };
        };
        i3 = {
          enable = true;
        };
      };
    };
  };
}
