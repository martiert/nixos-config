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
  nixos = ({ config, pkgs, lib, ... }: {
    cisco.services = {
      amp = {
        enable = true;
        overrideKernelVersion = false;
      };
      duo.enable = true;
    };

    imports = [
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

    age.secrets.citrix = {
      file = ../../secrets/citrix.age;
      owner = "martin";
    };

    fileSystems."/home/martin/src/Cisco" = {
      device = "/dev/disk/by-uuid/e2e37fd7-4a01-4386-90e0-20ea8f37fc64";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/865caa0b-41fe-4517-a429-63a5a8972328";
        keyFile = "/sysroot/etc/keys/cisco.key";
        label = "cisco";
      };
    };

    martiert = {
      system = {
        type = "desktop";
        gpu = "amd";
      };
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/1ade4779-c634-4797-b499-7f956920dfe9";
          useTpm2Device = true;
        };
        boot = "/dev/disk/by-uuid/2A5B-0C42";
        swap = "/dev/disk/by-partuuid/1bc95ed3-d38e-d64e-9410-43067e6cd4d5";
      };
      boot = {
        initrd.extraAvailableKernelModules = [ "usbhid" ];
        efi.removable = true;
      };
      services.xserver.defaultSession = "none+i3";
      virtd.enable = true;
      networking = {
        interfaces = {
          "eno1" = {
            enable = true;
            useDHCP = true;
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
          ./public_keys/pinarello.pub
          ./public_keys/cisco-vbox.pub
          ./public_keys/cisco-qemu.pub
        ];
      };
      terminal.fontSize = 14;
      citrix.enable = true;
      i3 = {
        enable = true;
        barSize = 12.0;
        statusBar = {
          extraDisks = {
            "Cisco" = "/home/martin/src/Cisco";
            "/boot" = "/boot";
          };
        };
      };
    };
    users = {
      users.hydra = {
        isNormalUser = true;
        openssh.authorizedKeys.keyFiles = [
          ./hydra.pub
        ];
      };
      groups = {
        hydra = {};
      };
    };

    home-manager.users.martin = { pkgs, config, ... }: {
      imports = [
        ./nix-updater
      ];

      config = {
        home.packages = [
          pkgs.vysor
          pkgs.teamctl
          pkgs.roomctl
        ];
        home.sessionVariables = {
          LYS_UTILS_CACHE_REMOTE_URL = "rsync://localhost:2226/tandberg-system";
        };

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
