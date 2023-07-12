{ nixpkgs
, ...}:

let
  system = "aarch64-linux";
in {
  inherit system;
  nixos = {
    imports = [
      ../../machines/sc8280xp
      ../../machines/mountpoints.nix
    ];
    nix.settings.trusted-users = [
      "root"
      "martin"
    ];
    networking = {
      useDHCP = false;
      resolvconf.enable = true;
      dhcpcd.extraConfig = "resolv.conf";
    };
    services.rsyslogd.enable = true;
    boot.loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = false;
      };
    };

    age.secrets."wpa_supplicant_wlan0".file = ../../secrets/wpa_supplicant_wireless.age;

    martiert = {
      system.type = "laptop";
      hardware.hidpi.enable = true;
      services.xserver.enable = true;
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/294031c9-eb35-4151-b78b-fb54af2162bb";
          device = "/dev/mapper/root";
        };
        boot = "/dev/disk/by-uuid/8E25-35C9";
      };
      sshd.enable = true;
      networking = {
        interfaces = {
          "wlan0" = {
            enable = true;
            supplicant.enable = true;
            useDHCP = true;
          };
        };
      };
    };
  
    home-manager.users.martin = {
      imports = [
        ../../settings/home-manager/all.nix
      ];
  
      home.stateVersion = "22.05";
      xsession.windowManager.i3.config = {
        startup = [
          { command = "alacritty"; }
          { command = "firefox"; }
        ];
        workspaceOutputAssign = [
          {
            output = "eDP-1";
            workspace = "1";
          }
        ];
        assigns = {
          "2" = [{ class = "^firefox$"; }];
        };
      };
      wayland.windowManager.sway.config = {
        startup = [
          { command = "alacritty"; }
          { command = "firefox"; }
        ];
        workspaceOutputAssign = [
          {
            output = "eDP-1";
            workspace = "1";
          }
        ];
        assigns = {
          "2" = [{ app_id = "^firefox$"; }];
        };
      };
      martiert = {
        i3status = {
          enable = true;
          networks = {
            wireless = [
              "wlan0"
            ];
          };
        };
        i3 = {
          enable = true;
        };
      };
    };
  };
}
