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
    imports = [
      ../../machines/x86_64.nix
      ../../machines/nvidia.nix
      ../../settings/nixos/configs/common.nix
      ../../settings/nixos/services/openssh.nix
    ];
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
      hardware.hidpi.enable = true;
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
    };

    home-manager.users.martin = {
      imports = [
        ../../settings/home-manager/all.nix
        ../../settings/home-manager/beltsearch.nix
        ../../settings/home-manager/x86_64-linux.nix
      ];

      home.stateVersion = "22.05";

      martiert = {
        i3status = {
          enable = true;
          ethernet.eno2 = 1;
        };
        i3 = {
          enable = true;
          barSize = 12.0;
        };
        email.enable = true;
      };
      xsession.windowManager.i3.config = swayi3Config // {
        assigns = {
          "2" = [{ class = "^webex$"; }];
          "9" = [{ class = "^Firefox$"; }];
        };
      };
      wayland.windowManager.sway.config = swayi3Config // {
        assigns = {
          "2" = [{ app_id = "^firefox$"; }];
          "3" = [{ app_id = "^webex$"; }];
        };
      };
    };
  };
}
