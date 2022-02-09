{ pkgs, ... }:

{
  imports = [
    ./xorg.nix
    ./printing.nix
  ];

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    extraConfig = ''unload-module module-switch-on-port-available'';
  };

  documentation.dev.enable = true;

  environment.systemPackages = [
    pkgs.git
    pkgs.nssmdns
    pkgs.man-pages
    pkgs.man-pages-posix
    pkgs.openconnect_openssl
    pkgs.openconnect-sso
    pkgs.git-crypt
  ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
}
