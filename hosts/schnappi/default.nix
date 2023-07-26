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
          device = "/dev/mapper/root";
          credentials = [
            "8ec94f82dc8eb3382933bda8306cd06c"
            "37e9d565bc83eb158b1b86bfb80a361e"
            "f79486f3c55f7a1c2af32cb8cf1df06f"
            "406c581bcfe4de3e83462b310dfc876c"
          ];
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
