{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    notify = {
      url = "github:martiert/khal_notifications";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blocklist = {
      url = "github:hagezi/dns-blocklists";
      flake = false;
    };
    module = {
      url = "github:martiert/nixos-module";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        blocklist.follows = "blocklist";
      };
    };
    cisco = {
      url = "git+ssh://git@sqbu-github.cisco.com/mertsas/nix-cisco";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, module, flake-utils, agenix, home-manager, nixos-generators, nixos-hardware, deploy-rs, notify, cisco, ... }@inputs:
    let
      lib = nixpkgs.lib.extend(self: super: (import ./lib) { 
        inherit nixpkgs module nixos-hardware home-manager agenix cisco notify;
        lib = super;
      });

      mkDeploy = name: config:
        {
          hostname = config.deployTo;
          profiles.system = {
            sshUser = "martin";
            user = "root";
            interactiveSudo = true;
            path = deploy-rs.lib."${config.system}".activate.nixos self.nixosConfigurations."${name}";
          };
        };
    in {
      nixosConfigurations = lib.forAllNixHosts lib.makeNixosConfig;
      homeConfigurations."mertsas" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          module.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              cisco.overlays.x86_64-linux
              module.overlays.x86_64-linux
              (import ./overlay/dummy.nix)
            ];

            home = {
              stateVersion = "23.05";
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
            ];
          }
        ];
      };
      deploy.nodes = 
        lib.forNixHostsWhere
          (config: builtins.hasAttr "deployTo" config)
          mkDeploy;

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      
      packages.x86_64-linux = {
        virtualbox = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "virtualbox";

          modules = [
            {
              nix.registry.nixpkgs.flake = nixpkgs;
              imports = [ ./virtualbox ];
            }
          ];
        };
      };
    };
    nixConfig = {
      substituters = [
        "https://cache.nixos.org"
        "https://cache.martiert.com"
      ];
    };
}
