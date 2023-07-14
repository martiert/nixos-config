{ lib, config, ...}:

with lib;

let
  martiert = config.martiert;
in {
  options = {
    martiert.system = {
      type = mkOption {
        type = types.enum [ "server" "desktop" "laptop" "wsl" ];
        description = "What type of system are we building?";
      };
    };
  };

  imports = [
    ./nixos-cache.nix
    ./mountpoints.nix
    ./allowedPackages.nix
    ./x86_64.nix
  ];
}
