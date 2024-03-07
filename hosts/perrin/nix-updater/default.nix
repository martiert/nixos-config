{ pkgs, ... }:

let
  nix-update = pkgs.stdenv.mkDerivation {
    pname = "nix-update";
    version = "1.0.0";

    src = ./.;

    doConfigure = false;
    doBuild = false;

    installPhase = ''
      mkdir --parent $out/bin
      cp nix-update.sh $out/bin/nix-update
    '';
  };
in {
  systemd.user.services.nix-updater = {
    Unit = {
      Description = "nix config updater";
      After = [ "network.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${nix-update}/bin/nix-update";
    };
    Install.WantedBy = [ "default.target" ];
  };
  systemd.user.timers.nix-updater = {
    Unit.Description = "nix config updater";
    Timer.OnCalendar = "20:00";
    Install.WantedBy = [ "timers.target" ];
  };

}
