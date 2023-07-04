{ config, pkgs, lib, ...}:

with lib;

let
  cfg = config.martiert.i3;
  modifier = config.xsession.windowManager.i3.config.modifier;
in {
  options.martiert.i3 = {
    enable = mkEnableOption "Enable i3";
    lockCmd = mkOption {
      type = types.str;
      default = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
      description = "Screen locking cmd";
    };
    barSize = mkOption {
      type = types.float;
      default = 14.0;
      description = "Font size for bars";
    };
  };

  config = {
    xsession.windowManager.i3 = {
      enable = cfg.enable;
      config = {
        modifier = "Mod1";
        terminal = "${pkgs.alacritty}/bin/alacritty";
        menu = "${pkgs.bemenu}/bin/bemenu-run";
        keybindings = mkOptionDefault {
          "${modifier}+Shift+l"     = "exec ${cfg.lockCmd}";
        };
        bars = [
          {
            trayOutput = "*";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs config-bottom.toml";
            fonts = {
              names = [ "DejaVu Sans Mono" "FontAwesome5Free" ];
              size = cfg.barSize;
            };
          }
        ];
        colors.background = "#000000";
      };
    };
    services.picom = {
      enable = true;
      vSync = true;
    };
    services.screen-locker = {
      enable = true;
      inactiveInterval = 10;
      lockCmd = cfg.lockCmd;
    };
  };
}
