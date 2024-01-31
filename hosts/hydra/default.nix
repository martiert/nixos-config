{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "hydra";

  nixos = ({ modulesPath, ... }: {
    imports = [
      "${toString modulesPath}/virtualisation/virtualbox-image.nix"
    ];

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
        ];
      };
    };
  });
}
