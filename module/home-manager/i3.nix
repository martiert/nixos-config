{ pkgs, lib, config, ...}:

with lib;

let
  cfg = config.martiert.i3;
  modifier = config.xsession.windowManager.i3.config.modifier;
in lib.mkIf (config.martiert.system.type != "server") {
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
}
