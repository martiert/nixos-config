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
      { command = "gimp"; }
    ];
    assigns = {
      "2" = [{ class = "^Firefox$"; }];
      "3" = [{ class = "^webex$"; }];
      "10" = [{ class = "^Gimp$"; }];
    };
  };
in {
  inherit system;
  nixos = {
    nixpkgs.overlays = [
      (import "${openconnect-sso}/overlay.nix")
      (import ../../overlay { inherit cisco vysor martiert system; })
    ];

    imports = [
      ../../machines/x86_64.nix
      ../../nixos/configs/common.nix
      ../../nixos/services/openssh.nix
      ../../nixos/services/nginx.nix
      ../../secrets/perrin_networking.nix
    ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    services.xserver = {
      videoDrivers = [ "nvidia" ];
    };

    age.secrets."wpa_supplicant.conf".file = ../../secrets/wpa_supplicant_wired.age;

    martiert = {
      mountpoints = {
        keyDisk.keyFile = "luks/perrin.key";
        root = {
          encryptedDevice = "/dev/disk/by-uuid/b13581fd-3fbe-4f00-85a7-35714bd8a48f";
          device = "/dev/disk/by-uuid/5deb8460-8f7a-4bfe-906e-76ef108c84f2";
        };
        boot = "/dev/disk/by-uuid/51EC-A800";
        swap = "/dev/disk/by-partuuid/cae6027b-e70b-4c66-b4fc-d15f71368b35";
      };
      boot = {
        initrd.extraAvailableKernelModules = [ "usbhid" ];
        efi.removable = true;
      };
      hardware.hidpi.enable = true;
      services.xserver = {
        defaultSession = "none+i3";
      };
      networking.interfaces = {
        "eno1" = {
          enable = true;
          useDHCP = true;
        };
        "enp3s0" = {
          enable = true;
          useDHCP = true;
          staticRoutes = true;
          supplicant = {
            enable = true;
            wired = true;
          };
        };
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

      xsession.windowManager.i3.config = swayi3Config;
      martiert = {
        alacritty.fontSize = 14;
        i3status = {
          enable = true;
          ethernet = {
            eno1 = 2;
            enp3s0 = 3;
          };
        };
        i3 = {
          enable = true;
        };
      };
    };
  };
}
