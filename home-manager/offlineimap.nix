{config, pkgs, ...}:

{
  programs.offlineimap = {
    enable = true;
  };

  accounts.email.accounts."Cisco" = {
    primary = true;
    address = "mertsas@cisco.com";
    imap = {
      host = "localhost";
      port = 1143;
      tls.enable  = false;
    };

    offlineimap = {
      enable = true;
      extraConfig = {
        local = {
          localfolders = ".mail";
        };
        remote = {
          remoteuser = "mertsas@cisco.com";
          holdconnectionopen = true;
          keepalive = 10;
          remotepass = "bogus!";
        };
      };
    };
  };
}
