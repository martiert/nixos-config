{ config, pkgs, lib, ... }:

{
  imports = [
    ./zsh.nix
    ./sway.nix
    ./i3.nix
    ./i3status.nix
    ./alacritty.nix
    ./vim.nix
    ./tmux.nix
    ./git.nix
    ./gpg.nix
    ./mail.nix
    ./direnv.nix
    ./weechat.nix
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.packages = with pkgs; [
    silver-searcher
    google-chrome
    firefox
    skypeforlinux
    steam
    gimp
    flashPrint

    #tools
    wget
    generate_ssh_key

    egl-wayland
    pulsemixer

    cura
    git-crypt

    vysor
    teamctl
    roomctl

    projecteur
    tmate
    spotify
    zoom-us
  ];
}
