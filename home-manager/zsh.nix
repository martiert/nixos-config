{ config, pkgs, ... }:

{
  programs.zsh = {
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
