{ config, ... }:

let
  cfg = config.martiert.sshd;
in  {
  users.users.root = {
    password = "changeme";
    openssh.authorizedKeys.keyFiles = cfg.authorizedKeyFiles;
  };

  security.sudo.extraConfig = ''
    Defaults targetpw
    Defaults env_keep+="EDITOR LANG LANGUAGE LC_*"
  '';
}
