{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.martiert.email;
in {
  options = {
    martiert.email = {
      enable = mkEnableOption "Enable email sync";
      address = mkOption {
        type = types.str;
        default = "";
      };
      davmail = mkOption {
        type = types.submodule {
          options = {
            imapPort = mkOption {
              type = types.int;
              default = 1143;
              description = "Port for davmail to listen to for IMAP";
            };
            caldavPort = mkOption {
              type = types.int;
              default = 1080;
              description = "Port for davmail to listen to for calendar";
            };

            o365 = mkOption {
              type = types.submodule {
                options = {
                  enable = mkEnableOption "Enable Office 365 sync";
                  clientId = mkOption {
                    type = types.str;
                    default = null;
                    description = "Client Id for O365 sync";
                  };
                  redirectUri = mkOption {
                    type = types.str;
                    default = "https://login.microsoftonline.com/common/oauth2/nativeclient";
                    description = "O365 redirect url";
                  };
                };
              };
              default = {};
            };
          };
        };
        default = {};
      };
      smtp = mkOption {
        type = types.submodule {
          options = {
            tls = mkOption {
              type = types.bool;
              default = true;
            };
            host = mkOption {
              type = types.str;
              default = "";
            };
          };
        };
      };
      imap = mkOption {
        type = types.submodule {
          options = {
            host = mkOption {
              type = types.str;
              default = "localhost";
            };
            port = mkOption {
              type = types.int;
              default = 1143;
            };
            tls = mkOption {
              type = types.bool;
              default = true;
            };
          };
        };
      };
    };
  };

  imports = [
    ./davmail.nix
    ../../secrets/mail_setup.nix
  ];

  config = mkIf cfg.enable {
    accounts.email = {
      maildirBasePath = ".mail";
      accounts.cisco = {
        primary = true;
        passwordCommand = "echo bogus";
        realName = "Martin Ertsås";
        userName = cfg.address;
        address = cfg.address;
        imap = {
          host = cfg.imap.host;
          port = cfg.imap.port;
          tls.enable = cfg.imap.tls;
        };
        smtp = {
          tls.enable = cfg.smtp.tls;
          host = cfg.smtp.host;
        };
        neomutt = {
          enable = true;
          extraConfig = ''
            set smtp_url = smtp://${cfg.smtp.host}
            set folder = /home/martin/.mail/cisco
            set spoolfile = +Inbox
            set record = +Sent
            set postponed = +Drafts
            set edit_headers = yes

            mailboxes "=Inbox"
            mailboxes "=Inbox/chromium"
            mailboxes "=Inbox/courses"
            mailboxes "=Inbox/jira"
            mailboxes "=Inbox/Patches"
            mailboxes "=Inbox/xapi"
            '';
        };
        mbsync = {
          enable = true;
          extraConfig.account = {
            AuthMechs = "LOGIN";
            Timeout = 0;
          };
          patterns = [
           "*"
           "!\"Archive/*\""
           "\"Archive/2020\""
           "!\"Conversation History\""
           "!\"Sync Issues*\""
           "!\"Social Activity Notifications\""
           "!\"Working Set\""
          ];
          create = "maildir";
          expunge = "both";
          remove = "maildir";
        };
      };
    };

    programs.mbsync.enable = true;
    programs.neomutt = {
      enable = true;
      settings = {
        sort = "threads";
        sort_aux = "last-date-received";

        charset = "utf-8";
        pager_index_lines = "6";
      };
      macros = [
        {
          map = [ "index" "pager" "attach" "compose" ];
          key = "\\cu";
          action = "<pipe-message> ${pkgs.urlscan}/bin/urlscan<Enter>";
        }
      ];
      extraConfig = ''
        color body green default "^diff \-.*"
        color body green default "^index [a-f0-9].*"
        color body green default "^\-\-\- .*"
        color body green default "^[\+]{3} .*"
        color body cyan default "^[\+][^\+]+.*"
        color body brightred  default "^\-[^\-]+.*"
        color body brightblue default "^@@ .*"
        
        color hdrdefault green default
        color quoted green black
        color signature green black
        color attachment red black
        color message brightred black
        color error brightred black
        color indicator cyan black
        color status white blue
        color tree green black
        color normal white black
        color markers red black
        color search white black
        color tilde brightmagenta black
        color index green black "~P"
        color index yellow black "~F"
        color index red black "~N|~O"

        auto_view text/html text/calendar
        unalternative_order text/enriched text/plain text
        alternative_order text/calendar text/html text/enriched text/plain text
        '';
    };

    home.file.".mailcap".text = ''
      text/calendar; ${pkgs.mutt-ics}/bin/mutt-ics %s; copiousoutput
      text/html; ${pkgs.links2}/bin/links -dump %s; copiousoutput
    '';

    services.mbsync = {
      enable = true;
      frequency = "*:0/5";
    };
  };
}
