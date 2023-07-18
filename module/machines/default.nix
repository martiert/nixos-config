{
  imports = [
    ./nixos-cache.nix
    ./mountpoints.nix
    ./allowedPackages.nix
    ./x86_64.nix
    ./amdgpu.nix
    ./nvidia.nix
    ./wsl.nix
    ./rpi3.nix
    ./sc8280xp
    ./boot.nix
  ];
  nix.settings.trusted-users = [
    "root"
    "martin"
  ];
}
