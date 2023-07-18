{ pkgs, lib, config, ... }:

{
  programs.zsh = lib.mkIf (config.martiert.system.type != "server") {
    enable = true;
    sessionVariables = {
      EDITOR = "vim";
    };
    oh-my-zsh = {
      enable = true;
      theme = "bira";
      plugins = [ "git" "python" "npm" "pip" ];
    };
  };
}
