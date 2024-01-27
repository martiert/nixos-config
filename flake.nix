{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    flake-utils.url = "github:numtide/flake-utils";
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
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, module, nixos-wsl, flake-utils, agenix, home-manager, nixos-generators, nixos-hardware, deploy-rs, cisco, ... }@inputs:
    let
      lib = nixpkgs.lib.extend(self: super: (import ./lib) { 
        inherit nixpkgs module nixos-hardware nixos-wsl home-manager agenix cisco;
        lib = super;
      });

      mkDeploy = name: filename: config:
        {
          hostname = config.deployTo;
          profiles.system = {
            sshUser = "martin";
            sshOpts = [ "-t" ];
            magicRollback = false;
            path = deploy-rs.lib."${config.system}".activate.nixos self.nixosConfigurations."${name}";
            user = "root";
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
              cisco.overlays.x86_64-linux.default
              module.overlays.x86_64-linux.default
              (import ./overlay { inherit nixpkgs; system = "x86_64-linux"; })
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
    };
}
