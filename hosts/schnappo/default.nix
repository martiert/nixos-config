{ nixpkgs
, ...}:

let
  system = "aarch64-linux";
in {
  inherit system;
  hw_modules = [];
  nixos = ({ pkgs, lib, config, secretsDir, ... }: {
    imports = [
      ./hardware.nix
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
    services.upower.enable = true;

    # No XCursor theme ships by default, and unlike X11 wlroots has no built-in
    # fallback cursor, so sway renders no pointer at all. Also needed system
    # wide for the sddm greeter.
    environment.systemPackages = [ pkgs.adwaita-icon-theme ];
    # WLR_NO_HARDWARE_CURSORS=1: Qualcomm MSM cursor planes are unreliable;
    # software cursor fallback is more robust on this hardware.
    environment.variables.WLR_NO_HARDWARE_CURSORS = "1";
    services.displayManager.sddm.settings.Theme.CursorTheme = "Adwaita";
    home-manager.users.martin.home.pointerCursor = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      sway.enable = true;
    };

    boot.initrd.systemd.tpm2.enable = false;
    systemd.tpm2.enable = false;
    hardware.bluetooth.enable = true;

    age.secrets."wpa_supplicant_wlP4p1s0".file = "${secretsDir}/wpa_supplicant_wireless.age";
    martiert = {
      system = {
        type = "laptop";
      };
      services.waylandOnly = true;
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/5399de08-ea02-453f-870c-d9e901a04724";
          useFido2Device = true;
        };
        boot = "/dev/disk/by-uuid/A2EB-BCC6";
      };
      sshd.enable = true;
      networking = {
        interfaces = {
          "wlP4p1s0" = {
            enable = true;
            supplicant = {
              enable = true;
              configFile = config.age.secrets.wpa_supplicant_wlP4p1s0.path;
            };
            useDHCP = true;
          };
        };
      };
      i3 = {
        enable = true;
      };
    };
  });
}
