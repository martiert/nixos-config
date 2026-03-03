{ ... }:

let
  setAuthorizedKeys = map builtins.readFile;
in {
  system = "x86_64-linux";
  config = { lib, ... }: let
    setAuthorizedKeys = files: lib.strings.concatStringsSep "\n" (map builtins.readFile files);
  in {
    home.file.".ssh/authorized_keys" = {
      enable = true;
      text = setAuthorizedKeys [
        ./public_keys/aginor.pub
      ];
    };

    martiert = {
      system.type = "desktop";
      i3.enable = true;
      terminal.fontSize = 14;
      email = {
        enable = true;
        address = "mertsas@cisco.com";
        smtp = {
          tls = false;
          host = "outbound.cisco.com:2525";
        };
        imap.tls = false;
        davmail = {
          o365 = {
            enable = true;
            clientId = "953f4ef4-80ac-48d1-b98c-f66f227bb094";
          };
        };
      };
    };
  };
}
