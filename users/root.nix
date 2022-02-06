{
  users.users.root.initialPassword = "changeme";

  security.sudo.extraConfig = ''
    Defaults targetpw
    Defaults env_keep = "EDITOR LANG LANGUAGE LC_*"
  '';
}
