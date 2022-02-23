{ nixpkgs
, openconnect-sso
, martiert
, cisco
, webex-linux
, vysor
, ...}:

let
  system = "x86_64-linux";
in {
  inherit system;
  nixos = ({modulesPath, ...}: {
    nixpkgs.overlays = [
      (import "${openconnect-sso}/overlay.nix")
      (import martiert)
      (self: super: {
        vysor = super.callPackage vysor {};
        teamctl = cisco.outputs.packages."${system}".teamctl;
        roomctl = cisco.outputs.packages."${system}".roomctl;
      })
    ];

    imports = [
      ../../machines/x86_64.nix
      ../../nixos/configs/common.nix
      ../../nixos/services/openssh.nix
    ];
    networking.hostName = "aginor";
    networking.useDHCP = false;
    networking.interfaces.eno2.useDHCP = true;

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      xrandrHeads = [
        "DP-2"
        "DP-0"
      ];
    };

    fileSystems."/media/div" = {
      device = "/dev/disk/by-uuid/c67f1d64-2b82-46a6-99b1-cc446a859e1a";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/f3e30761-85f8-4510-b267-84fa5c7b6f5e";
        keyFile = "/mnt-root/etc/keys/div.key";
        label = "div";
      };
    };

    martiert = {
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
        irssi = {
          enable = true;
          nick = "martiert_work";
        };
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
            output = "DP-2";
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