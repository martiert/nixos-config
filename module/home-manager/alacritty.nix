{ lib, config, ... }:

let
  cfg = config.martiert.alacritty;
in lib.mkIf (config.martiert.system.type != "server") {
  programs.alacritty = {
    enable = true;
    settings = {
      window.decorations = "none";

      font = {
        size = cfg.fontSize;
      };

      colors = {
        primary = {
          background = "#000000";
        };

        normal = {
          green = "#75bd64";
        };
      };
    };
  };
}
