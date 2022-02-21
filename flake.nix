{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    openconnect-sso = {
      url = "github:vlaci/openconnect-sso";
      flake = false;
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    martiert = {
      url = "github:martiert/nix-overlay";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cisco.url = "git+ssh://git@sqbu-github.cisco.com/mertsas/nix-overlay?ref=main";
    webex-linux.url = "git+ssh://git@sqbu-github.cisco.com/Nix/webex-linux-nix?ref=main";
    vysor = {
      url = "git+ssh://git@sqbu-github.cisco.com/CE/vysor";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, deploy-rs, home-manager, openconnect-sso, martiert, cisco, webex-linux, vysor, ... }@inputs: 
    let
      mkHost = filename:
        let
          config = import filename {
            inherit nixpkgs home-manager openconnect-sso martiert cisco webex-linux vysor deploy-rs;
          };
        in nixpkgs.lib.nixosSystem {
          system = config.system;
          modules = [
            ./nixos/configs/timezone.nix
            ./nixos/configs/fonts.nix
            ./nixos/configs/networking.nix
            ./nixos/users/martin.nix
            ./nixos/users/root.nix

            config.nixos
            home-manager.nixosModules.home-manager
            {
              nix.registry.nixpkgs.flake = nixpkgs;
            }
            config.home-manager
          ];
        };
    in {
      nixosConfigurations = {
        octoprint = mkHost ./hosts/octoprint;
        pihole = mkHost ./hosts/pihole;
        moghedien = mkHost ./hosts/moghedien;
        moridin = mkHost ./hosts/moridin;
      };
      deploy.nodes = {
        octoprint = {
          hostname = "octoprint.localdomain";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.octoprint;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
