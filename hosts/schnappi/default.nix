{ nixpkgs
, ...}:

let
  system = "aarch64-linux";
in {
  inherit system;
  nixos = ({ pkgs, config, ... }: {
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

    environment.systemPackages = [ pkgs.modemmanager ];
    services.udev.packages = [ pkgs.modemmanager ];
    services.dbus.packages = [ pkgs.modemmanager ];
    systemd.packages = [ pkgs.modemmanager ];

    systemd.units.ModemManager.enable = true;
    networking.networkmanager = {
      unmanaged = [ "wlan0" ];
      enable = true;
      fccUnlockScripts = [
        {
          id = "105b:e0c3";
          path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b:e0c3";
        }
      ];
    };

    boot.loader.efi.canTouchEfiVariables = false;

    age.secrets."wpa_supplicant_wlan0".file = ../../secrets/wpa_supplicant_wireless.age;

    martiert = {
      system = {
        type = "laptop";
        aarch64.arch = "sc8280xp";
      };
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/2a70888f-653f-4ac0-9af3-b7174dd2ee24";
          useFido2Device = true;
        };
        boot = "/dev/disk/by-uuid/CB01-CD14";
      };
      sshd.enable = true;
      networking = {
        interfaces = {
          "wlan0" = {
            enable = true;
            supplicant = {
              enable = true;
              configFile = config.age.secrets."wpa_supplicant_wlan0".path;
            };
            useDHCP = true;
          };
          "wwan0" = {
            enable = false; # WWAN0 is a wan interface, not managed by supplicant
          };
        };
      };
      i3.enable = true;
    };
  
    home-manager.users.martin = { pkgs, config, ... }: {
      config = {
        home.packages = [
          pkgs.vysor
          pkgs.teamctl
          pkgs.roomctl
        ];

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
      };
    };
  });
}
