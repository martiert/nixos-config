{ pkgs, ... }:

{
  imports = [
    ../../nixos/users/root.nix
    ../../nixos/users/martin.nix
    ../../nixos/services/openssh.nix
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

  martiert = {
    sshd = {
      enable = true;
      authorizedKeyFiles = [
        ./public_keys/aginor.pub
      ];
    };
  };
}
