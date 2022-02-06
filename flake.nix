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
  };

  outputs = { self, nixpkgs, home-manager, openconnect-sso, martiert, ... }@inputs: {
    nixosConfigurations = {
      octoprint = import ./hosts/octoprint.nix {
        inherit nixpkgs;
      };
      moghedien = import ./hosts/moghedien.nix {
        inherit nixpkgs home-manager openconnect-sso martiert;
      };
    };
  };
}
