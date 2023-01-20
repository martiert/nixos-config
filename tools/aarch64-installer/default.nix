{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_0;
  hardware.deviceTree = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    git-crypt
    gnupg
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "tty";
  };

  networking.wireless = {
    enable = true;
  };

  environment.etc."gnupg/keys.pub".source = ../../settings/home-manager/keys.pub;

  environment.loginShellInit = ''
    ${pkgs.gnupg}/bin/gpg --import /etc/gnupg/keys.pub
  '';

  system.stateVersion = "22.05";

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
}
