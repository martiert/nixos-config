{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.martiert.sshd;
in {
  options = {
    martiert.sshd = {
      enable = mkEnableOption "Enable sshd";
      authorizedKeyFiles = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "List of files to add to users authorized keys";
      };
    };
  };

  config = {
    users = {
      users.martin = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "video" "uucp" ];
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
