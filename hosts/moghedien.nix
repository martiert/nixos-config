{ nixpkgs, home-manager, openconnect-sso, martiert, ...}:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ({modulesPath, ...}: {
      nixpkgs.overlays = [
        (import "${openconnect-sso}/overlay.nix")
        (import "${martiert}")
      ];

      imports = [
        ../machines/laptop.nix
      ];
      networking.hostName = "moghedien";
    })
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.martin = {
        imports = [
          ../home-manager/all.nix
        ];

        martiert = {
          i3status = {
            enable = true;
            wireless = {
              wlp1s0 = 1;
            };
            battery = true;
          };
          i3 = {
            enable = true;
            barSize = 10.0;
          };
        };
      };
    }
  ];
}
