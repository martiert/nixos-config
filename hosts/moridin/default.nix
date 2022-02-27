{ nixpkgs
, openconnect-sso
, martiert
, cisco
, webex-linux
, vysor
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = left: middle: right: {
    startup = [
      { command = "firefox"; }
      { command = "alacritty"; }
      { command = "CiscoCollabHost"; }
      { command = "gimp"; }
    ];
    assigns = {
      "2" = [{ class = "^Firefox$"; }];
      "3" = [{ class = "^webex$"; }];
      "10" = [{ class = "^Gimp$"; }];
    };
    workspaceOutputAssign = [
      {
        output = left;
        workspace = "9";
      }
      {
        output = right;
        workspace = "10";
      }
      {
        output = middle;
        workspace = "1";
      }
      {
        output = middle;
        workspace = "2";
      }
      {
        output = middle;
        workspace = "3";
      }
    ];
  };
in {
  inherit system;
  nixos = {
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
      ../../nixos/services/openssh.nix
      ../../secrets/moridin_networking.nix
    ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    services.xserver = {
      xrandrHeads = [
        "DP-2-2"
        "DP-2-1"
        "DP-1"
      ];
    };

    martiert = {
      mountpoints = {
        keyDisk.keyFile = "luks/moridin.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/4ea0a56f-90d0-48ad-a5f2-80befab4b826";
          device = "/dev/disk/by-label/nixos";
        };
        boot = "/dev/disk/by-label/boot";
        swap = "/dev/disk/by-partuuid/54830ffa-cb0b-4a6f-b79b-ab162f4bd009";
      };
      boot.initrd.extraAvailableKernelModules = [ "usbhid" "rtsx_pci_sdmmc" ];
      hardware.hidpi.enable = true;
      services.xserver = {
        defaultSession = "none+i3";
      };
      sshd.enable = true;
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.martin = {
      imports = [
        ../../home-manager/all.nix
      ];

      home.packages = [
        webex-linux.packages."${system}".webexWayland
      ];

      xsession.windowManager.i3.config = swayi3Config "DP-2-2" "DP-2-1" "DP-1";
      wayland.windowManager.sway.config = (swayi3Config "DP-4" "DP-3" "DP-1") //
        {
          output = {
            "DP-4" = { pos = "0 0"; };
            "DP-3" = { pos = "3840 0"; };
            "DP-1" = { pos = "7680 540"; };
          };
          input = {
            "type:tablet_tool" = {
              map_to_output = "DP-1";
            };
          };
        };

      martiert = {
        alacritty.fontSize = 14;
        i3status = {
          enable = true;
          ethernet = {
            eno1 = 2;
            enp0s20f0u3 = 3;
          };
        };
        i3 = {
          enable = true;
        };
        email.enable = true;
        irssi.enable = true;
      };
    };
  };
}
