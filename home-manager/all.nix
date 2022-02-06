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
    ./irssi.nix
    ./direnv.nix
  ];

  home.packages = with pkgs; [
    silver-searcher
    google-chrome
    firefox
    skype
    steam

    #tools
    wget
    generate_ssh_key

    egl-wayland
    pulsemixer

    cura
    git-crypt

    vysor
  ];
}
