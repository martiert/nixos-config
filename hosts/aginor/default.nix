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
      virtd.enable = true;
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
      email = {
        enable = true;
        address = "mertsas@cisco.com";
        smtp = {
          tls = false;
          host = "outbound.cisco.com";
        };
        imap.tls = false;
        davmail = {
          o365 = {
            enable = true;
            clientId = "953f4ef4-80ac-48d1-b98c-f66f227bb094";
          };
        };
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

        services.dunst = {
          enable = true;
          settings.global = {
            width = 600;
            offset = "50x50";
            origin = "top-right";
            font = "Noto Fonts 22";
            background = "#777777";
            frame_color = "#777777";
          };
        };
        systemd.user.services.khal-notify = {
          Unit = {
            Description = "Khal calendar notifications";
            After = [ "network.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.khal_notify}/bin/khal-notify";
          };
        };
        systemd.user.timers.khal-notify = {
          Unit.Description = "Khal calendar notifications";
          Timer.OnCalendar = "*:0/1";
          Install.WantedBy = [ "timers.target" ];
        };

        programs.khal.enable = true;
        services.vdirsyncer.enable = true;
        programs.vdirsyncer.enable = true;
        accounts.calendar = {
          basePath = ".calendars";
          accounts."cisco" = {
            khal = {
              addresses = [ "mertsas@cisco.com" ];
              enable = true;
              type = "discover";
            };
            local = {
              type = "filesystem";
            };
            remote = {
              type = "caldav";
              url = "http://localhost:1080/users/mertsas@cisco.com/calendar/";
              userName = "mertsas@cisco.com";
              passwordCommand = ["echo" "bogus"];
            };
            vdirsyncer = {
              enable = true;
              auth = "basic";
              metadata = ["color" "displayname"];
              collections = ["from a" "from b"];
              conflictResolution = "remote wins";
            };
          };
        };

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
