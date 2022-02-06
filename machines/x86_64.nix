{ pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.pcscd.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "cnijfilter2"
    "google-chrome"
    "skypeforlinux"
    "steam"
    "steam-original"
    "steam-runtime"
    "teamctl"
    "roomctl"
    "webex-linux"
  ];

  hardware.enableRedistributableFirmware = true;

  services.udev.packages = [ pkgs.projecteur ];
}
