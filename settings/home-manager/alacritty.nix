{ config, lib, ... }:

with lib;

let
  cfg = config.martiert.alacritty;
in {
  options.martiert.alacritty = {
    fontSize = mkOption {
      type = types.int;
      default = 10;
      description = "Fontsize to use";
    };
  };


  config.programs.alacritty = {
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
