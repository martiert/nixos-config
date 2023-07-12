{ pkgs, lib, config, ... }:

with lib;

let
  martiert = config.martiert;
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

  imports = [
    ./openssh.nix
  ];
}
