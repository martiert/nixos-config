{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    openconnect-sso = {
      url = "github:vlaci/openconnect-sso";
      flake = false;
    };
    martiert = {
      url = "github:martiert/nix-overlay";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cisco = {
      url = "git+ssh://git@sqbu-github.cisco.com/mertsas/nix-overlay?ref=main";
      flake = false;
    };
    webex-linux.url = "git+ssh://git@sqbu-github.cisco.com/Nix/webex-linux-nix?ref=main";
    vysor = {
      url = "git+ssh://git@sqbu-github.cisco.com/CE/vysor";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, openconnect-sso, martiert, cisco, webex-linux, vysor, ... }@inputs: 
    let
      mkHost = filename:
        let
          config = import filename {
            inherit nixpkgs home-manager openconnect-sso martiert cisco webex-linux vysor;
          };
        in nixpkgs.lib.nixosSystem {
          system = config.system;
          modules = [
            ./nixos/configs/timezone.nix
            ./nixos/configs/fonts.nix
            ./nixos/users/martin.nix
            ./nixos/users/root.nix

            config.nixos
            home-manager.nixosModules.home-manager
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
  };
}
