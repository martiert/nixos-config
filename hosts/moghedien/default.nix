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
        output = "eDP-1";
        workspace = "1";
      }
      {
        output = "eDP-1";
        workspace = "2";
      }
      {
        output = "eDP-1";
        workspace = "3";
      }
    ];
  };

in {
  inherit system;
  nixos = ({ config, ... }: {
    networking.useDHCP = false;
    networking.resolvconf.enable = true;
    networking.dhcpcd.extraConfig = "resolv.conf";

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25591_key" ];
    age.secrets."wpa_supplicant_wlp1s0".file = ../../secrets/wpa_supplicant_wireless.age;

    martiert = {
      system.type = "laptop";
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/90041fed-c9a4-4139-a61d-76c6c4aca100";
        };
        boot = "/dev/disk/by-uuid/C414-3256";
        swap = "/dev/disk/by-partuuid/813b7f11-8581-4af9-839c-c46e0be03f39";
      };
      networking.interfaces = {
        "wlp1s0" = {
          enable = true;
          supplicant = {
            enable = true;
            configFile = config.age.secrets.wpa_supplicant_wlp1s0.path;
          };
          useDHCP = true;
        };
      };
      i3 = {
        enable = true;
        barSize = 10.0;
      };
    };

    home-manager.users.martin = { pkgs, config, ... }: {
      config = {
        home.packages = [
          pkgs.vysor
          pkgs.teamctl
          pkgs.roomctl
        ];

        xsession.windowManager.i3.config = swayi3Config //
          {
            assigns = {
              "2" = [{ class = "^Firefox$"; }];
              "3" = [{ class = "^webex$"; }];
              "10" = [{ class = "^Gimp$"; }];
            };
          };

        wayland.windowManager.sway.config = swayi3Config //
          {
            input = {
              "type:tablet_tool" = {
                map_to_output = "HDMI-A-1";
              };
            };
            assigns = {
              "2" = [{ app_id = "^firefox$"; }];
              "3" = [{ app_id = "^webex$"; }];
              "10" = [{ class = "^Gimp$"; }];
            };
          };
      };
    };
  });
}
