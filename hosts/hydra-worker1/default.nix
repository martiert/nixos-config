{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "hydra-worker1";

  nixos = ({ modulesPath, pkgs, ... }: {
    imports = [
      "${toString modulesPath}/virtualisation/virtualbox-image.nix"
    ];
    nix = {
      package = pkgs.nixVersions.latest;
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
    };

    martiert = {
      system = {
        type = "server";
      };
      networking.interfaces = {
        "enp0s3" = {
          enable = true;
          useDHCP = true;
        };
      };
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/aginor.pub
          ./public_keys/hydra.pub
        ];
      };
    };
  });
}
