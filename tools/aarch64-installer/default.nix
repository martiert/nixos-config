{ pkgs, config, ... }:

let
  dtbName = "sc8280xp-lenovo-thinkpad-x13s.dtb";
in {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "dtb=/boot/aarch64/${dtbName}"
  ];
  isoImage.contents = [
    {
      source = "${config.boot.kernelPackages.kernel}/dtbs/qcom/${dtbName}";
      target = "boot/aarch64/${dtbName}";
    }
  ];
  hardware.deviceTree = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  networking.wireless = {
    enable = true;
  };

  system.stateVersion = "23.05";

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
}
