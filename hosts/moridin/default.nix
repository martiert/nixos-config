{ nixpkgs
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = left: middle: right: {
    startup = [
      { command = "firefox"; }
      { command = "alacritty"; }
      { command = "webex"; }
      { command = "gimp"; }
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
      ../../settings/nixos/services/dnsproxy.nix
    ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
    networking.networkmanager = {
      enable = true;
      unmanaged = [ "enp0s20f0u3" ];
      dns = "dnsmasq";
      dhcp = "dhcpcd";
    };

    services.xserver = {
      xrandrHeads = [
        "DP-2-2"
        "DP-2-1"
        "DP-1"
      ];
    };

    age.secrets."wpa_supplicant_enp0s20f0u3".file = ../../secrets/wpa_supplicant_wired.age;
    age.secrets."dns_servers".file = ../../secrets/dns_servers.age;

    martiert = {
      mountpoints = {
        keyDisk.keyFile = "luks/moridin.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/4ea0a56f-90d0-48ad-a5f2-80befab4b826";
          device = "/dev/disk/by-label/nixos";
        };
        boot = "/dev/disk/by-label/boot";
        swap = "/dev/disk/by-partuuid/54830ffa-cb0b-4a6f-b79b-ab162f4bd009";
      };
      boot.initrd.extraAvailableKernelModules = [ "usbhid" "rtsx_pci_sdmmc" ];
      hardware.hidpi.enable = true;
      services.xserver = {
        defaultSession = "none+i3";
      };
      sshd.enable = true;
      networking = {
        dhcpcd.leaveResolveConf = true;
        interfaces = {
          "eno1" = {
            enable = true;
            useDHCP = true;
          };
          "enp0s20f0u3" = {
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
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.martin = {
      imports = [
        ../../settings/home-manager/all.nix
        ../../settings/home-manager/x86_64-linux.nix
      ];

      home.stateVersion = "22.05";

      xsession.windowManager.i3.config = swayi3Config "DP-2-2" "DP-2-1" "DP-1";
      wayland.windowManager.sway.config = (swayi3Config "DP-4" "DP-3" "DP-1") //
        {
          output = {
            "DP-4" = { pos = "0 0"; mode = "3840x2160@30Hz"; };
            "DP-3" = { pos = "3840 0"; mode = "3840x2160@30Hz"; };
            "DP-1" = { pos = "7680 540"; mode = "1920x1080@30Hz"; };
          };
          input = {
            "type:tablet_tool" = {
              map_to_output = "DP-1";
            };
          };
        };

      martiert = {
        alacritty.fontSize = 14;
        i3status = {
          enable = true;
          ethernet = {
            eno1 = 2;
            enp0s20f0u3 = 3;
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
