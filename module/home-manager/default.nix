{ pkgs, lib, config, ... }:

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
    ./x86_64-linux.nix
  ];

  config = lib.mkIf (config.martiert.system.type != "server") {
    home.sessionVariables = {
      EDITOR = "vim";
    };

    home.packages = with pkgs; [
      silver-searcher
      firefox
      gimp

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

      tmate
    ];
  };
}
