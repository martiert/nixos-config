{ nixpkgs
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = left: middle: right: {
    startup = [
      # { command = "xrandr --output HDMI-A-0 --right-of HDMI-0 --output DP-1 --right-of HDMI-1"; }
      { command = "alacritty"; }
      { command = "firefox"; }
      { command = "webex"; }
      { command = "gimp"; }
      { command = "xsetwacom --set \"Wacom Cintiq 16 Pen stylus\" MapToOutput ${right}"; }
      { command = "xsetwacom --set \"Wacom Cintiq 16 Pen eraser\" MapToOutput ${right}"; }
    ];
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
      ./networkRestart.nix
      ./nginx
      ../../machines/amdgpu.nix
    ];

    services.xserver = {
      enable = true;
      xrandrHeads = [
        "HDMI-A-0"
        "DisplayPort-0"
        "DisplayPort-1"
      ];
    };

    age.secrets."wpa_supplicant_enp6s0".file = ../../secrets/wpa_supplicant_wired.age;
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
      system.type = "desktop";
      dnsproxy.enable = true;
      printing.enable = true;
      services.xserver.enable = true;
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/34185190-271f-464b-91aa-d6707835ab60";
          device = "/dev/disk/by-uuid/29a4d0df-3ec4-4b32-914a-9329d4b18c99";
          credentials = [
            "7a1b48e5df7fe3f91fc7b44a5404a6a2"
            "629a8ce0e10987d16ea20dc186aac48c"
            "1b633076d0cef092511ad5beca0ab1c5"
          ];
        };
        boot = "/dev/disk/by-uuid/34F2-B158";
        swap = "/dev/disk/by-partuuid/1bc95ed3-d38e-d64e-9410-43067e6cd4d5";
      };
      boot = {
        initrd.extraAvailableKernelModules = [ "usbhid" ];
        efi.removable = true;
      };
      hardware.hidpi.enable = true;
      # hardware.nvidia.openDriver = false;
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
          "enp6s0" = {
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
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/aginor.pub
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/schnappi.pub
          ./public_keys/mattrim.pub
        ];
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

      xsession.windowManager.i3.config = swayi3Config "HDMI-A-0" "DisplayPort-0" "DisplayPort-1" //
        {
          assigns = {
            "9" = [{ class = "^Firefox$"; }];
            "2" = [{ class = "^webex$"; }];
            "10" = [{ class = "^Gimp$"; }];
          };
        };


      wayland.windowManager.sway.config = swayi3Config "HDMI-A-1" "DP-1" "DP-2" //
        {
          assigns = {
            "9" = [{ app_id = "^firefox$"; }];
            "2" = [{ app_id = "^webex$"; }];
            "10" = [{ app_id = "^gimp$"; }];
          };
        };

      martiert = {
        alacritty.fontSize = 14;
        i3status = {
          enable = true;
          networks = {
            ethernet = [
              "eno1"
              "enp6s0"
            ];
          };
          extraDisks = {
            "Cisco" = "/home/martin/Cisco";
            "/storage" = "/storage";
            "/boot" = "/boot";
          };
        };
        i3 = {
          enable = true;
          barSize = 12.0;
        };
        email.enable = true;
      };
    };
  };
}
