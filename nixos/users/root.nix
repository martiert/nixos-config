{
  users.users.root.hashedPassword = "$6$VGThpAsyRYUyByGh$8yEK4hRDdEplKAtgWK9bSMQUZc9SebSiVCEVup.w5MFjaEE.Z2jw.1kUYDBM8I23erOITb4CloNLVyFIz8e4h1";

  security.sudo.extraConfig = ''
    Defaults targetpw
    Defaults env_keep = "EDITOR LANG LANGUAGE LC_*"
  '';
}
