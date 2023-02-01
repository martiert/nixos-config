{ nixpkgs
, nixos-wsl
, lib
, agenix
, home-manager
, cisco
, vysor
, beltsearch
, blocklist
, ...}:

let
  isNixFile = {name, type}: type == "directory" || lib.strings.hasSuffix ".nix" name;
  nixFiles = folder:
    let
      content = builtins.readDir folder;
      contentList = lib.mapAttrsToList (name: type: { inherit name type;}) content;
    in
    builtins.filter isNixFile contentList;

  hosts = builtins.map (x: x.name) (nixFiles ../hosts);
  importConfig = name:
    let
      filename = ../hosts/${name};
      config = import filename {
        inherit nixpkgs home-manager;
      };
    in {
      name = name;
      config = config;
      filename = filename;
    };
in rec {
  forNixHostsWhere = predicate: func:
    let
      predicateCheck = entry: predicate entry.config;
      makeAttr = entry: {
        name = entry.name;
        value = func entry.name entry.filename entry.config;
      };

      configs = builtins.map importConfig hosts;
      acceptedConfigs = builtins.filter predicateCheck configs;
    in
      lib.listToAttrs (builtins.map makeAttr acceptedConfigs);

  forAllNixHosts = forNixHostsWhere (_: true);

  makeNixosConfig = name: filename: config:
    nixpkgs.lib.nixosSystem {
      system = config.system;
      modules = [
        ../settings/nixos/configs/timezone.nix
        ../settings/nixos/configs/fonts.nix
        ../settings/nixos/users/martin.nix
        ../settings/nixos/users/root.nix
        ../settings/nixos/configs/networking
        config.nixos
        nixos-wsl.nixosModules.wsl
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          system.stateVersion = "23.05";
          wsl.defaultUser = "martin";

          environment.variables.EDITOR = "vim";
          environment.variables.MOZ_ENABLE_WAYLAND = "1";
          environment.systemPackages = [ agenix.packages."${config.system}".default ];

          networking.hostName = name;

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          nix.registry.nixpkgs.flake = nixpkgs;
          nixpkgs.overlays = [
            (import ../overlay { inherit nixpkgs cisco vysor beltsearch blocklist; system = config.system; })
          ];
        }
      ];
    };
}
