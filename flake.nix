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
        lib = super;
      });
    in {
      nixosConfigurations = lib.forAllNixHosts lib.makeNixosConfig;
      homeConfigurations."mertsas" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          module.nixosModules.home-manager
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
    };
    nixConfig = {
      substituters = [
        "https://cache.nixos.org"
        "https://cache.martiert.com"
      ];
    };
}
