{ config, pkgs, ...}:

let
  cfg = config.martiert.i3;
in {
  wayland.windowManager.sway = {
    enable = true;
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland
    '';
    config = {
      terminal = "${pkgs.alacritty}/bin/alacritty";
      startup = [
        {
          always = true;
          command = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 000000' timeout 600 '${pkgs.sway}/bin/swaymsg \"output * dpms off\"' resume '${pkgs.sway}/bin/swaymsg \"output * dpms on\"' before-sleep '${pkgs.swaylock}/bin/swaylock -f -c 000000'";
        }
      ];
      menu = "${pkgs.bemenu}/bin/bemenu-run";
      bars = [
        {
          trayOutput = "*";
          statusCommand = "${pkgs.i3status}/bin/i3status";
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
    extraOptions = [ "--my-next-gpu-wont-be-nvidia" ];
  };
}
