{ nixpkgs, ... }:

nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
        ../machines/rpi3.nix
        ../secrets/home_wireless.nix
        ../users/martin.nix
        ../users/root.nix
        ../services/openssh.nix
        ../services/pihole.nix
        ../configs/timezone.nix
      ];

      networking.hostName = "pihole2";
    })
  ];
}
