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
  importConfig = name:
    let
      filename = ../hosts/${name};
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

      configs = builtins.map importConfig hosts;
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
        home-manager.nixosModules.home-manager
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

      configs = builtins.map importConfig home-manager;
    in
      lib.listToAttrs (builtins.map makeAttr configs);
      
  makeHomeConfiguration = name: config:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [
        module.nixosModules.home-manager
        config
        {
          nixpkgs.overlays = [
            module.overlays.x86_64-linux
            (import ./overlay/dummy.nix)
          ];

          home = {
            stateVersion = "26.05";
            username = "mertsas";
            homeDirectory = "/home/mertsas";
          };
          programs.zsh.envExtra = "PATH=/home/mertsas/.nix-profile/bin:$PATH";
          # programs.tmux.shell = "$SHELL";
          targets.genericLinux.enable = true;
          martiert = {
            system.type = "laptop";
            i3 = {
              enable = true;
            };
          };
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "google-chrome"
            "zoom"
            "webex"
            "spotify"
            "steam"
            "steam-original"
            "steam-unwrapped"
          ];
        }
      ];
    };
}
