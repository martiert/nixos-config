{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.martiert.sshd;
in {
  config = {
    programs.zsh.enable = true;
    users = {
      users.martin = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "video" "uucp" "adbusers" ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keyFiles = cfg.authorizedKeyFiles;
        hashedPassword = "$6$nUFj3gT/oPluqWtN$2kfFlSYw7XBlEDlhJgWi2whyWxEuKP7pnquExp7vbBftQiGfzoFtpZ/.exIsnPrv023BFRv7L0RjVzIAJ4e1b0";
      };
      groups = {
        martin = {};
      };
    };
  };
}
