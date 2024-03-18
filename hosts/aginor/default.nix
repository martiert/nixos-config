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
    cisco.services = {
      amp = {
        enable = true;
        overrideKernelVersion = false;
      };
      duo.enable = true;
    };

    virtualisation = {
      docker.enableNvidia = true;
      virtualbox.host = {
        enable = true;
        headless = true;
      };
    };

    services.xserver = {
      xrandrHeads = [
        "USB-C-0"
        "DP-0"
      ];
    };

    age.secrets.citrix = {
      file = ../../secrets/citrix.age;
      owner = "martin";
    };

    fileSystems."/home/martin/src/Cisco" = {
      device = "/dev/disk/by-uuid/bb99b78e-bb87-4a60-af06-de8a9fd87952";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/67ab45c6-1231-4ebe-b518-f3d0b8ffb1b0";
        keyFile = "/sysroot/etc/keys/cisco.key";
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
          useTpm2Device = true;
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
          ./public_keys/mertsas-l-PF3K63V3.pub
          ./public_keys/pinarello.pub
        ];
      };
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
      citrix.enable = true;
    };

    home-manager.users.martin = { pkgs, config, ... }: {
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
