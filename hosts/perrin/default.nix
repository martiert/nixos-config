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
  nixos = ({ config, ... }: {
    cisco.services.amp = {
      enable = true;
      overrideKernelVersion = false;
    };

    imports = [
      ./networkRestart.nix
      ./nginx
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

    fileSystems."/home/martin/src/Cisco" = {
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
      system = {
        type = "desktop";
        gpu = "amd";
      };
      dnsproxy.enable = true;
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
      services.xserver.defaultSession = "none+i3";
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
              configFile = config.age.secrets.wpa_supplicant_enp6s0.path;
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
          ./public_keys/mertsas-l-PF3K63V3.pub
        ];
      };
      alacritty.fontSize = 14;
      i3 = {
        enable = true;
        barSize = 12.0;
        statusBar = {
          extraDisks = {
            "Cisco" = "/home/martin/Cisco";
            "/storage" = "/storage";
            "/boot" = "/boot";
          };
        };
      };
    };

    home-manager.users.martin = { pkgs, config, ... }: {
      config = {
        home.packages = [
          pkgs.vysor
          pkgs.teamctl
          pkgs.roomctl
        ];

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
      };
    };
  });
}
