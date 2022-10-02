{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.martiert.email;

  # Disable JavaFX to use the simple pop-up
  jre = pkgs.openjdk.override {
    enableJavaFX = false;
  };
  # Use jetbrains.jdk for JavaFX support
  # jre = pkgs.jetbrains.jdk;

  # davmail = pkgs.davmail;
  davmail = pkgs.davmail.override {
    inherit jre;
  };

in {
  config = mkIf cfg.enable {
    home.packages = [
      davmail
    ];

    home.file.".davmail.properties".text = ''
      davmail.server=true
      davmail.allowRemote=false
      davmail.disableUpdateCheck=true

      # Send keepalive character during large folder and messages download
      davmail.enableKeepalive=false
      # Message count limit on folder retrieval
      davmail.folderSizeLimit=0

      # Delete messages immediately on IMAP STORE \Deleted flag
      # davmail.imapAutoExpunge=true
      # Enable IDLE support, set polling delay in minutes
      davmail.imapIdleDelay=
      # Always reply to IMAP RFC822.SIZE requests with Exchange approximate message size for performance reasons
      davmail.imapAlwaysApproxMsgSize=

      # SSL
      davmail.ssl.nosecureimap=true

      # log file path, leave empty for default path
      davmail.logFilePath=./logs/davmail.log
      # maximum log file size, use Log4J syntax, set to 0 to use an external rotation mechanism, e.g. logrotate
      davmail.logFileSize=1MB
      # log levels
      log4j.logger.davmail=INFO
      log4j.logger.httpclient.wire=WARN
      log4j.logger.org.apache.commons.httpclient=WARN
      log4j.rootLogger=INFO
    '' + (if ! cfg.davmail.o365.enable then "" else ''
        davmail.mode=O365Interactive
        davmail.url=https://outlook.office365.com/EWS/Exchange.asmx
        davmail.oauth.clientId=${cfg.davmail.o365.clientId}
        davmail.oauth.redirectUri=${cfg.davmail.o365.redirectUri}
        davmail.oauth.persistToken=true
        davmail.imapPort=${toString cfg.davmail.imapPort}
        davmail.caldavPort=${toString cfg.davmail.caldavPort}
      '');

    systemd.user.services.davmail = {
      Unit = {
        Description = "Davmail Exchange IMAP Proxy";
        After = "graphical-session-pre.target";
        PartOf = "graphical-session.target";
      };

      Service = {
        Environment = "PATH=${pkgs.davmail}/bin:${pkgs.coreutils}/bin:${pkgs.xdg-utils}/bin:${pkgs.firefox}/bin";
        ExecStart = "${davmail}/bin/davmail";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
