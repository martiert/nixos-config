{ lib, ... }:

with lib;

{
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
}
