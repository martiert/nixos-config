{ pkgs, ... }:

{
  systemd.user.services.beltsearch = {
    Unit = {
      Description = "Searching for ninja belts";
    };

    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir --parent /home/martin/.cache/beltsearch";
      ExecStart = "${pkgs.beltsearch}/bin/beltsearch --outfile /home/martin/.cache/beltsearch/belts.json";
      Type = "oneshot";
    };
  };
  systemd.user.timers.beltsearch = {
    Unit = {
      Description = "Timer for running ninja belt search";
    };

    Timer = {
      OnCalendar = "Mon..Fri 09:30";
      Unit = "beltsearch.service";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
