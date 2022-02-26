{ nixpkgs
, openconnect-sso
, martiert
, cisco
, webex-linux
, vysor
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = {
    startup = [
      { command = "alacritty"; }
      { command = "firefox"; }
      { command = "CiscoCollabHost"; }
    ];
    assigns = {
      "2" = [{ class = "^Firefox$"; }];
      "3" = [{ class = "^webex$"; }];
      "10" = [{ class = "^Gimp$"; }];
    };
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
  nixos = ({modulesPath, ...}: {
    nixpkgs.overlays = [
      (import "${openconnect-sso}/overlay.nix")
      (self: super: {
        vysor = super.callPackage vysor {};
        teamctl = cisco.outputs.packages."${system}".teamctl;
        roomctl = cisco.outputs.packages."${system}".roomctl;
        projecteur = martiert.outputs.packages."${system}".projecteur;
        mutt-ics = martiert.outputs.packages."${system}".mutt-ics;
        generate_ssh_key = martiert.outputs.packages."${system}".generate_ssh_key;
      })
    ];

    imports = [
      ../../machines/x86_64.nix
      ../../nixos/configs/common.nix
    ];
    networking.useDHCP = false;
    networking.resolvconf.enable = true;
    networking.dhcpcd.extraConfig = "resolv.conf";

    networking.interfaces.wlp1s0.useDHCP = true;

    networking.hostName = "moghedien";
    martiert = {
      mountpoints = {
        keyDisk.keyFile = "luks/moghedien.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/90041fed-c9a4-4139-a61d-76c6c4aca100";
          device = "/dev/disk/by-uuid/747150e3-46c0-41a2-8735-3c042dec1d2d";
        };
        boot = "/dev/disk/by-uuid/C414-3256";
        swap = "/dev/disk/by-partuuid/813b7f11-8581-4af9-839c-c46e0be03f39";
      };
      networking.wireless = {
        enable = true;
        interfaces = [ "wlp1s0" ];
      };
    };
  });

  home-manager = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.martin = {
      imports = [
        ../../home-manager/all.nix
      ];

      home.packages = [
        webex-linux.packages."${system}".webexWayland
      ];

      xsession.windowManager.i3.config = swayi3Config;
      wayland.windowManager.sway.config = swayi3Config //
        {
          input = {
            "type:tablet_tool" = {
              map_to_output = "HDMI-A-1";
            };
          };
        };

      martiert = {
        i3status = {
          enable = true;
          wireless = {
            wlp1s0 = 1;
          };
          battery = true;
        };
        i3 = {
          enable = true;
          barSize = 10.0;
        };
      };
    };
  };
}
