{ nixpkgs
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = {
    startup = [
      { command = "alacritty"; }
      { command = "firefox"; }
      { command = "webex"; }
    ];
    workspaceOutputAssign = [
      {
        output = "USB-C-0";
        workspace = "9";
      }
      {
        output = "DP-0";
        workspace = "1";
      }
      {
        output = "DP-0";
        workspace = "2";
      }
    ];
  };
in {
  inherit system;
  nixos = {
    virtualisation = {
      docker.enableNvidia = true;
    };

    services.xserver = {
      xrandrHeads = [
        "USB-C-0"
        "DP-0"
      ];
    };

    fileSystems."/home/martin/Cisco" = {
      device = "/dev/disk/by-uuid/bb99b78e-bb87-4a60-af06-de8a9fd87952";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/67ab45c6-1231-4ebe-b518-f3d0b8ffb1b0";
        keyFile = "/mnt-root/etc/keys/cisco.key";
        label = "cisco";
      };
    };

    martiert = {
      system = {
        type = "desktop";
        gpu = "nvidia";
      };
      networking = {
        interfaces = {
          "eno2" = {
            enable = true;
            useDHCP = true;
          };
        };
      };
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/cd5f221d-597c-4c35-b95a-8194a672859d";
          device = "/dev/disk/by-label/rootfs";
          credentials = [
            "e65c251fd417d92e856dd2c161cd804f"
            "1dc9dfa64910dae1f48bda53b81ab719"
          ];
        };
        boot = "/dev/disk/by-label/boot";
      };
      boot.initrd.extraAvailableKernelModules = [ "usbhid" "rtsx_pci_sdmmc" ];
      hardware.nvidia.openDriver = true;
      services.xserver = {
        defaultSession = "none+i3";
      };
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/mattrim.pub
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/perrin.pub
          ./public_keys/schnappi.pub
        ];
      };
      i3 = {
        enable = true;
        barSize = 12.0;
        statusBar = {
          extraDisks = {
            "Cisco" = "/home/martin/Cisco";
            "/boot" = "/boot";
          };
        };
      };
    };

    home-manager.users.martin = { pkgs, config, ... }: {
      imports = [
        ./beltsearch.nix
      ];

      config = {
        home.packages = [
          pkgs.vysor
          pkgs.teamctl
          pkgs.roomctl
        ];
        xsession.windowManager.i3.config = swayi3Config // {
          assigns = {
            "2" = [{ class = "^webex$"; }];
            "9" = [{ class = "^Firefox$"; }];
          };
        };
        wayland.windowManager.sway.config = swayi3Config // {
          assigns = {
            "9" = [{ app_id = "^firefox$"; }];
            "2" = [{ app_id = "^webex$"; }];
          };
        };
      };
    };
  };
}
