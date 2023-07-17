{ lib, config, ...}:

with lib;

let
  martiert = config.martiert;
in {
  options = {
    martiert = {
      system = {
        type = mkOption {
          type = types.enum [ "server" "desktop" "laptop" "wsl" ];
          description = "What type of system are we building?";
        };
        gpu = mkOption {
          type = types.nullOr (types.enum [ "amd" "nvidia" "intel" ]);
          default = null;
          description = "GPU to use for this device";
        };
      };
      hardware.nvidia = {
        openDriver = lib.mkEnableOption "Enable using the open nvidia driver";
      };
    };
  };

  imports = [
    ./nixos-cache.nix
    ./mountpoints.nix
    ./allowedPackages.nix
    ./x86_64.nix
    ./amdgpu.nix
    ./nvidia.nix
  ];
}
