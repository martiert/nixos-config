{ nixpkgs
, module
, lib
, agenix
, nixos-hardware
, home-manager
, notify
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
  home-manager-files = builtins.map (x: x.name) (nixFiles ../home-manager);

  importConfig = path: name:
    let
      filename = "${path}/${name}";
      config = { hw_modules = []; } // (import filename {
        inherit nixpkgs home-manager nixos-hardware;
      });
    in {
      name = name;
      config = config;
    };
in rec {
  forNixHostsWhere = predicate: func:
    let
      predicateCheck = entry: predicate entry.config;
      makeAttr = entry: {
        name = entry.name;
        value = func entry.name entry.config;
      };

      configs = builtins.map (importConfig ../hosts) hosts;
      acceptedConfigs = builtins.filter predicateCheck configs;
    in
      lib.listToAttrs (builtins.map makeAttr acceptedConfigs);

  forAllNixHosts = forNixHostsWhere (_: true);

  makeNixosConfig = name: config:
    nixpkgs.lib.nixosSystem {
      system = config.system;
      modules = config.hw_modules ++ [
        config.nixos
        module.nixosModules.default
        agenix.nixosModules.default
        home-manager.nixosModules.default
        {
          system.stateVersion = "26.05";

          environment.variables.EDITOR = "vim";
          environment.variables.MOZ_ENABLE_WAYLAND = "1";
          environment.systemPackages = [ agenix.packages."${config.system}".default ];

          networking.hostName = name;

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.martin = { lib, config, osConfig, ... }: {
              imports = [
                module.nixosModules.home-manager
              ];
              config = {
                martiert = lib.mkDefault osConfig.martiert;
                home.stateVersion = osConfig.system.stateVersion;
              };
            };
          };

          nix = {
            registry.nixpkgs.flake = nixpkgs;
            settings = {
              substituters = [ "https://cache.martiert.com" ];
              trusted-public-keys = [
                "hydra.martiert.com:+bsrgpsujBGQ/LzA6ixlmB7RFUuEd1b3zY9wAxxLAYE="
              ];
            };
          };
          nixpkgs = {
            overlays = [
              module.overlays."${config.system}"
              (self: super: {
                khal_notify = notify.packages."${config.system}".default;
              })
            ];
            config.permittedInsecurePackages = [
              "olm-3.2.16"
            ];
          };
        }
      ];
    };

  forAllHomeManagerHosts = func:
    let
      makeAttr = entry: {
        name = entry.name;
        value = func entry.name entry.config;
      };

      configs = builtins.map (importConfig ../home-manager) home-manager-files;
    in
      lib.listToAttrs (builtins.map makeAttr configs);

  getUsername = str: lib.head (lib.strings.splitString "@" str);
}
