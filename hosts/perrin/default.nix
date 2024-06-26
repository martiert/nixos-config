{ nixpkgs
, ...}:

let
  system = "x86_64-linux";
  swayi3Config = left: middle: right: {
    startup = [
      # { command = "xrandr --output HDMI-A-0 --right-of HDMI-0 --output DP-1 --right-of HDMI-1"; }
      { command = "alacritty"; }
      { command = "firefox"; }
      { command = "webex"; }
      { command = "gimp"; }
      { command = "xsetwacom --set \"Wacom Cintiq 16 Pen stylus\" MapToOutput ${right}"; }
      { command = "xsetwacom --set \"Wacom Cintiq 16 Pen eraser\" MapToOutput ${right}"; }
    ];
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
  nixos = ({ config, pkgs, lib, ... }: {
    cisco.services = {
      amp = {
        enable = true;
        overrideKernelVersion = false;
      };
      duo.enable = true;
    };

    imports = [
      ./nginx
    ];

    i18n.extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8";
    };

    services.xserver = {
      enable = true;
      xrandrHeads = [
        "HDMI-A-0"
        "DisplayPort-0"
        "DisplayPort-1"
      ];
    };

    age.secrets.citrix = {
      file = ../../secrets/citrix.age;
      owner = "martin";
    };

    fileSystems."/home/martin/src/Cisco" = {
      device = "/dev/disk/by-uuid/e2e37fd7-4a01-4386-90e0-20ea8f37fc64";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/865caa0b-41fe-4517-a429-63a5a8972328";
        keyFile = "/sysroot/etc/keys/cisco.key";
        label = "cisco";
      };
    };

    networking.hosts = {
      "127.0.0.1" = [ "outbound.cisco.com" ];
    };

    hardware.printers = {
      ensurePrinters = [
        {
          name = "Canon_Pixma_TS8350";
          location = "Home";
          deviceUri = "ipps://192.168.1.218";
          model = "canonts8300.ppd";
        }
      ];
      ensureDefaultPrinter = "Canon_Pixma_TS8350";
    };

    martiert = {
      system = {
        type = "desktop";
        gpu = "amd";
      };
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/1ade4779-c634-4797-b499-7f956920dfe9";
          useTpm2Device = true;
        };
        boot = "/dev/disk/by-uuid/2A5B-0C42";
        swap = "/dev/disk/by-partuuid/1bc95ed3-d38e-d64e-9410-43067e6cd4d5";
      };
      boot = {
        initrd.extraAvailableKernelModules = [ "usbhid" ];
        efi.removable = true;
      };
      services.xserver.defaultSession = "none+i3";
      virtd.enable = true;
      networking = {
        interfaces = {
          "eno1" = {
            enable = true;
            useDHCP = true;
          };
        };
      };
      email = {
        enable = true;
        address = "mertsas@cisco.com";
        smtp = {
          tls = false;
          host = "outbound.cisco.com:2525";
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
          ./public_keys/aginor.pub
          ./public_keys/moghedien.pub
          ./public_keys/moridin.pub
          ./public_keys/schnappi.pub
          ./public_keys/mattrim.pub
          ./public_keys/mertsas-l-PF3K63V3.pub
          ./public_keys/pinarello.pub
          ./public_keys/cisco-vbox.pub
          ./public_keys/cisco-qemu.pub
        ];
      };
      terminal.fontSize = 14;
      citrix.enable = true;
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
    };
    users = {
      users.hydra = {
        isNormalUser = true;
        openssh.authorizedKeys.keyFiles = [
          ./hydra.pub
        ];
      };
      groups = {
        hydra = {};
      };
    };

    home-manager.users.martin = { pkgs, config, ... }: {
      imports = [
        ./nix-updater
      ];

      config = {
        home.packages = [
          pkgs.vysor
          pkgs.teamctl
          pkgs.roomctl
          pkgs.khal_notify
        ];
        home.sessionVariables = {
          LYS_UTILS_CACHE_REMOTE_URL = "rsync://localhost:2226/tandberg-system";
        };

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

        xsession.windowManager.i3.config = swayi3Config "HDMI-A-0" "DisplayPort-0" "DisplayPort-1" //
          {
            assigns = {
              "9" = [{ class = "^Firefox$"; }];
              "2" = [{ class = "^webex$"; }];
              "10" = [{ class = "^Gimp$"; }];
            };
          };


        wayland.windowManager.sway.config = swayi3Config "HDMI-A-1" "DP-1" "DP-2" //
          {
            assigns = {
              "9" = [{ app_id = "^firefox$"; }];
              "2" = [{ app_id = "^webex$"; }];
              "10" = [{ app_id = "^gimp$"; }];
            };
          };
      };
    };
  });
}
