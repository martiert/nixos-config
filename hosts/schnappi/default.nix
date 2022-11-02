{ nixpkgs
, ...}:

let
  system = "aarch64-linux";
in {
  inherit system;
  nixos = {
    imports = [
      ../../settings/nixos/services/openssh.nix
      ../../settings/nixos/configs/common.nix
      ../../machines/wsl.nix
    ];
    nix.settings.trusted-users = [
      "root"
      "martin"
    ];
  
    martiert = {
      sshd.enable = true;
    };
  
    home-manager.users.martin = {
      imports = [
        ../../settings/home-manager/all.nix
      ];
  
      home.stateVersion = "22.05";
    };
  };
}
