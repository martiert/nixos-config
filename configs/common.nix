{
  imports = [
    ./timezone.nix
    ./fonts.nix
    ./xorg.nix
    ./printing.xorg
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  services.printing.enable = true;

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
