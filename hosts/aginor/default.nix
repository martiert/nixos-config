{ nixpkgs
, openconnect-sso
, webex-linux
, ...}:

let
  system = "x86_64-linux";
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
    ];
    virtualisation = {
      virtualbox.host = {
        enable = true;
        enableExtensionPack = true;
      };
      docker.enableNvidia = true;
    };

    services.xserver = {
      videoDrivers = [ "nvidia" ];
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
        keyDisk.keyFile = "luks/aginor.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/cd5f221d-597c-4c35-b95a-8194a672859d";
          device = "/dev/disk/by-label/rootfs";
        };
        boot = "/dev/disk/by-label/boot";
      };
      boot.initrd.extraAvailableKernelModules = [ "usbhid" "rtsx_pci_sdmmc" ];
      hardware.hidpi.enable = true;
      services.xserver = {
        defaultSession = "none+i3";
      };
      sshd.enable = true;
    };

    home-manager.users.martin = {
      imports = [
        ../../settings/home-manager/all.nix
        ../../settings/home-manager/beltsearch.nix
      ];

      home.stateVersion = "22.05";
      home.packages = [
        webex-linux.packages."${system}".webexWayland
      ];

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
      xsession.windowManager.i3.config = {
        startup = [
          { command = "firefox"; }
          { command = "alacritty"; }
          { command = "CiscoCollabHost"; }
        ];
        assigns = {
          "2" = [{ class = "^webex$"; }];
          "9" = [{ class = "^Firefox$"; }];
        };
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
    };
  };
}
