{ pkgs, lib, config, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "citrix" ''
      ${pkgs.citrix_workspace}/bin/wfica -icaroot ${pkgs.citrix_workspace}/opt/citrix-icaclient ${config.age.secrets.citrix.path}
    '')
  ];

  environment.etc.icaclient = {
    enable = true;
    source = ./icaclient;
  };

  systemd.services."ctxcwalogd" = {
    enable = true;
    description = "Citrix Log Daemon Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart="${pkgs.citrix_workspace}/opt/citrix-icaclient/util/ctxcwalogd";
      User="citrixlog";
    };
  };

  users = {
    users.citrixlog = {
      isSystemUser = true;
      group = "citrixlog";
      shell = "/bin/sh";
      home = "/var/log/citrix";
      createHome = true;
    };
    groups = {
      citrixlog = {};
      citrix = {};
    };
  };
}
