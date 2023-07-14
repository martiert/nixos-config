{ pkgs, lib, config, ... }:

with lib;

let
  martiert = config.martiert;
  isPersonalPC = builtins.elem martiert.system.type [ "desktop" "laptop" "wsl" ];
in {
  imports = [
    ./xorg.nix
    ./printing.nix
    ./timezone.nix
    ./fonts.nix
    ./networking
  ];

  config = {
    sound.enable = isPersonalPC;
    hardware.pulseaudio = mkIf isPersonalPC {
      enable = true;
      extraConfig = ''unload-module module-switch-on-port-available'';
      support32Bit = (pkgs.system == "x86_64-linux");
    };

    documentation.dev.enable = isPersonalPC;

    environment.systemPackages = mkIf isPersonalPC [
      pkgs.git
      pkgs.nssmdns
      pkgs.man-pages
      pkgs.man-pages-posix
      pkgs.git-crypt
    ];

    nix = lib.mkIf isPersonalPC {
      package = pkgs.nixUnstable;
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
    };
  };
}
