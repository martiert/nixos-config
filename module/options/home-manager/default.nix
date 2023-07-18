{ lib, ... }:

with lib;

{
  imports = [
    ./i3status.nix
    ./mail.nix
  ];

  options.martiert.alacritty = {
    fontSize = mkOption {
      type = types.int;
      default = 10;
      description = "Fontsize to use";
    };
  };
}
