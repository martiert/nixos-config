{ pkgs, ... }:

let
  networks = import ../../secrets/networks.nix;
in {
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
    networks = {
      "402 Payment Required" = {
        pskRaw = networks.home;
        priority = 6;
      };
      "blizzard" = {
        auth = ''
          eap=PEAP
          identity="${networks.cisco.identity}"
          password="${networks.cisco.password}"
          phase2="auth=MSCHAPV2"
        '';
        authProtocols=[ "WPA-EAP" ];
      };
      "snowstorm" = {
        auth = ''
          eap=PEAP
          identity="${networks.cisco.identity}"
          password="${networks.cisco.password}"
          phase2="auth=MSCHAPV2"
        '';
        authProtocols=[ "WPA-EAP" ];
      };
    };
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
