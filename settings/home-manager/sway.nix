{ config, pkgs, lib, ...}:

let
  cfg = config.martiert.i3;
  modifier = config.wayland.windowManager.sway.config.modifier;
  lockCmd = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
in {
  wayland.windowManager.sway = {
    enable = true;
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland
    '';
    config = {
      terminal = "${pkgs.alacritty}/bin/alacritty";
      keybindings = lib.mkOptionDefault {
        "${modifier}+0"       = "workspace number 10";
        "${modifier}+Shift+0" = "move container to workspace number 10";
        "${modifier}+Shift+l" = "exec ${lockCmd}";
      };
      startup = [
        {
          always = true;
          command = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 000000' timeout 600 '${pkgs.sway}/bin/swaymsg \"output * dpms off\"' resume '${pkgs.sway}/bin/swaymsg \"output * dpms on\"' before-sleep '${lockCmd}'";
        }
      ];
      menu = "${pkgs.bemenu}/bin/bemenu-run";
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
      input = {
        "*" = {
          xkb_layout = "us";
          xkb_options = "caps:none,compose:lwin";
        };
      };
    };
  };
}
