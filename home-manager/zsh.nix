{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    sessionVariables = {
      EDITOR = "${pkgs.vim}/bin/vim";
    };
    oh-my-zsh = {
      enable = true;
      theme = "bira";
      plugins = [ "git" "python" "npm" "pip" ];
    };
  };
}
