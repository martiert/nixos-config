{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.martiert.i3status;
  settingsType = with types; attrsOf (oneOf [ bool int str ]);
  ethernet_settings = iface: {
    format_up = "${iface}: %ip";
    format_down = "${iface} down";
  };
  wifi_settings = iface: {
    format_up = " (%quality at %essid) %ip";
    format_down = "${iface} down";
    format_quality = "%03d%s";
  };
  network_entry = prefix: settings: iface: position: nameValuePair ("${prefix} ${iface}") ({
    position = position;
    settings = settings iface;
  });
  ethernet_entries = mapAttrs' (network_entry "ethernet" ethernet_settings) cfg.ethernet;
  wifi_entries = mapAttrs' (network_entry "wireless" wifi_settings) cfg.wireless;
in {
  options = {
    martiert.i3status = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      ethernet = mkOption {
        type = types.attrsOf types.int;
        default = {};
      };
      wireless = mkOption {
        type = types.attrsOf types.int;
        default = {};
      };
      battery = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = {
    programs.i3status = {
      enable = cfg.enable;
      enableDefault = false;
  
      general = {
        colors = true;
        color_good = "#ffffff";
        color_degraded = "#d7ae00";
        color_bad = "#f60d00";
      };
  
      modules = ethernet_entries // wifi_entries // {
        "battery all" = {
          enable = cfg.battery;
          position = 10;
          settings = {
            integer_battery_capacity = true;
            format = "%status %percentage";
            format_down = "";
            status_chr = "";
            status_bat = "";
            status_unk = "?";
            status_full = "";
            low_threshold = 10;
          };
        };

        memory = {
          position = 11;
          settings = {
            format = " %percentage_used";
            threshold_degraded = "10%";
            threshold_critical = "5%";
          };
        };
  
        cpu_usage = {
          position = 12;
          settings = {
            format = " %usage";
            degraded_threshold = 75;
            max_threshold = 95;
          };
        };
  
        "cpu_temperature 0" = {
          position = 13;
          settings = {
            format = " %degrees°C";
            max_threshold = 60;
          };
        };
  
        "disk /" = {
          position = 14;
          settings = {
            format = " %percentage_used";
            low_threshold = 10;
          };
        };
  
        "time" = {
          position = 15;
          settings = {
            format = "%Y-%m-%d %H:%M:%S";
          };
        };
      };
    };
  };
}
