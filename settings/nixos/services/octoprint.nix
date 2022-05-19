{ pkgs, lib, ... }:

{
  services.octoprint = {
    enable = true;
    plugins = plugins: with plugins; [
      firmwareupdater
      bedlevelvisualizer
    ];
    extraConfig = {
      plugins = {
        firmwareupdater = {
          "_config_version" = 3;
          "_selected_profile" = 0;
          profiles = [
            {
              "_id" = 0;
              "_name" = "Default";
              avrdude_path = "${pkgs.avrdude}/bin/avrdude";
              avrdude_programmer = "wiring";
              avrdude_avrmcu = "m2560";
              flash_method = "avrdude";
              serial_port = "/dev/ttyUSB0";
              enable_postflash_commandline = true;
            }
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 5000 ];
}
