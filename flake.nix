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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, module, flake-utils, agenix, home-manager, nixos-hardware, notify, ... }@inputs:
    let
      lib = nixpkgs.lib.extend(self: super: (import ./lib) { 
        inherit nixpkgs module nixos-hardware home-manager agenix notify;
        secretsDir = ./secrets;
        lib = super;
      });
    in {
      nixosConfigurations = lib.forAllNixHosts lib.makeNixosConfig;
      homeConfigurations = lib.forAllHomeManagerHosts (name: config:
        let
          system = config.system;
          username = lib.getUsername name;
        in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            module.nixosModules.home-manager
            agenix.homeManagerModules.default
            config.config
            {
              nixpkgs.overlays = [
                module.overlays."${system}"
                (import ./overlay/dummy.nix)
              ];

              home = {
                stateVersion = "26.05";
                username = username;
                homeDirectory = "/home/${username}";
              };
              programs.zsh.envExtra = "PATH=/home/mertsas/.nix-profile/bin:$PATH";

              # programs.tmux.shell = "$SHELL";
              targets.genericLinux.enable = true;
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
        });
    };
    nixConfig = {
      substituters = [
        "https://cache.nixos.org"
        "https://cache.martiert.com"
      ];
    };
}
