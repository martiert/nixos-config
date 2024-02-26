{
  systemd.user.services.nix-updater = {
    Unit = {
      Description = "nix config updater";
      After = [ "network.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = ./nix-update.sh;
    };
    Install.WantedBy = [ "default.target" ];
  };
  systemd.user.timers.nix-updater = {
    Unit.Description = "nix config updater";
    Timer.OnCalendar = "20:00";
    Install.WantedBy = [ "timers.target" ];
  };

}
