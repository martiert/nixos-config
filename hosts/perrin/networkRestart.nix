{ pkgs, lib, ...}:

let
  restartScript = pkgs.writeShellScript "restartNetwork" ''
        ${pkgs.systemd}/bin/systemctl restart supplicant-enp6s0
        ${pkgs.systemd}/bin/systemctl restart network-addresses-enp6s0
  '';
in {
  systemd.services.networkRestart = {
    description = "Restart the network stack";

    serviceConfig = {
      ExecStart = "${restartScript}";
      Type = "oneshot";
    };
  };

  systemd.timers.networkRestart = {
    description = "Timer for restarting the network stack";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "12h";
      OnUnitActiveSec = "12h";
      Unit = "networkRestart.service";
    };
  };
}
