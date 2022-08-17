{ nixpkgs
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = left: middle: right: {
    startup = [
      { command = "xrandr --output HDMI-1 --right-of HDMI-0 --output DP-1 --right-of HDMI-1"; }
      { command = "alacritty"; }
      { command = "firefox"; }
      { command = "webex"; }
      { command = "gimp"; }
      { command = "xsetwacom --set \"Wacom Cintiq 16 Pen stylus\" MapToOutput HEAD-2"; }
      { command = "xsetwacom --set \"Wacom Cintiq 16 Pen eraser\" MapToOutput HEAD-2"; }
    ];
    assigns = {
      "9" = [{ class = "^Firefox$"; }];
      "2" = [{ class = "^webex$"; }];
      "10" = [{ class = "^Gimp$"; }];
    };
    workspaceOutputAssign = [
      {
        output = left;
        workspace = "9";
      }
      {
        output = right;
        workspace = "10";
      }
      {
        output = middle;
        workspace = "1";
      }
      {
        output = middle;
        workspace = "2";
      }
      {
        output = middle;
        workspace = "3";
      }
    ];
  };
in {
  inherit system;
  nixos = {
    imports = [
      ../../machines/x86_64.nix
      ../../settings/nixos/configs/common.nix
      ../../settings/nixos/services/openssh.nix
      ../../settings/nixos/services/nginx.nix
      ../../settings/nixos/services/dnsproxy.nix
    ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      xrandrHeads = [
        "HDMI-0"
        "HDMI-1"
        "DP-1"
      ];
    };
    networking.networkmanager = {
      enable = true;
      unmanaged = [ "enp4s0" ];
      dns = "dnsmasq";
      dhcp = "dhcpcd";
    };

    age.secrets."wpa_supplicant_enp4s0".file = ../../secrets/wpa_supplicant_wired.age;
    age.secrets."dns_servers".file = ../../secrets/dns_servers.age;

    fileSystems."/home/martin/Cisco" = {
      device = "/dev/disk/by-uuid/e2e37fd7-4a01-4386-90e0-20ea8f37fc64";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/865caa0b-41fe-4517-a429-63a5a8972328";
        keyFile = "/mnt-root/etc/keys/cisco.key";
        label = "cisco";
      };
    };
    fileSystems."/storage" = {
      device = "/dev/disk/by-uuid/025bf0b4-8400-4e48-a077-0613326f9558";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/d62f0219-ee11-4d13-ac6c-e033ea8fef79";
        keyFile = "/mnt-root/etc/keys/storage.key";
        label = "storage";
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

      home.stateVersion = "22.05";

      xsession.windowManager.i3.config = swayi3Config "HDMI-0" "HDMI-1" "DP-1";
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
        email.enable = true;
      };
    };
  };
}
