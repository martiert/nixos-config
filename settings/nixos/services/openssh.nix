{ pkgs, config, lib, ... }:

let
  cfg = config.martiert.sshd;
in {
  services.openssh = {
    enable = cfg.enable;
    allowSFTP = true;
    hostKeys = [ { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }];
    passwordAuthentication = false;
  };
}
