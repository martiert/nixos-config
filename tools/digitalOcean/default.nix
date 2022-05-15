{ pkgs, ... }:

{
  imports = [
    ../../settings/nixos/users/root.nix
    ../../settings/nixos/users/martin.nix
    ../../settings/nixos/services/openssh.nix
    ../../machines/nixos-cache.nix
  ];
  virtualisation.digitalOcean = {
    setRootPassword = false;
    setSshKeys = false;
  };

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
  system.stateVersion = "22.05";

  martiert = {
    sshd = {
      enable = true;
      authorizedKeyFiles = [
        ./public_keys/aginor.pub
      ];
    };
  };
}
