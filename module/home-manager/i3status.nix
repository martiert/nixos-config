{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.martiert;

  networkBlocks = let
      createWifiBlock = iface: {
        block = "net";
        format = "$icon ${iface}: $ip ($ssid)|${iface}: Not connected";
        missing_format = "${iface}: Down";
        device = iface;
      };
      createEthernetBlock = iface: {
        block = "net";
        format = "$icon ${iface}: $ip|${iface}: Not connected";
        missing_format = "";
        device = iface;
      };

      wifiNetworkBlocks = ifaces:
        map createWifiBlock ifaces;
      ethernetNetworkBlocks = ifaces:
        map createEthernetBlock ifaces;

      isWireless = _: value: value.supplicant.enable && !value.supplicant.wired;
      isWired = name: value: !(isWireless name value);

      wirelessInterfaces = interfaces:
        attrNames (filterAttrs isWireless interfaces);
      ethernetInterfaces = interfaces:
        attrNames (filterAttrs isWired interfaces);

    in
      networks:
        wifiNetworkBlocks (wirelessInterfaces networks) ++ ethernetNetworkBlocks (ethernetInterfaces networks);


  extraDiskEntries = let
      makeDiskEntry = name: path: {
        block = "disk_space";
        format = "$icon ${name} $percentage";
        icons_format = " ";
        path = path;
        alert_unit = "GB";
        warning = 10;
        alert = 5;
      };
    in entries:
      mapAttrsToList makeDiskEntry entries;
in {
  programs.i3status-rust = let
    diskEntries = { "/" = "/"; } // cfg.i3.statusBar.extraDisks;
  in {
    enable = cfg.i3.enable;
    bars.bottom = {
      icons = "awesome4";
      blocks = networkBlocks cfg.networking.interfaces ++ [
        {
          block = "battery";
          format = "$icon $percentage $time";
          driver = "upower";
          missing_format = "";
        }
        {
          block = "memory";
          format = "$icon $mem_used/$mem_total";
        }
        {
          block = "cpu";
          format = "$icon $utilization";
        }
        {
          block = "temperature";
          format = "$icon $max";
        }
      ] ++ extraDiskEntries diskEntries ++ [
        {
          block = "time";
          format = "$timestamp.datetime(f:'%Y-%m-%d %H:%M:%S')";
          interval = 1;
        }
      ];
    };
  };
}
