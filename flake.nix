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
    webex-linux.url = "git+file:///home/martin/Cisco/nix/webex-linux-nix?ref=main";
    vysor = {
      url = "git+ssh://git@sqbu-github.cisco.com/CE/vysor";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, openconnect-sso, martiert, cisco, webex-linux, vysor, ... }@inputs: {
    nixosConfigurations = {
      octoprint = import ./hosts/octoprint.nix {
        inherit nixpkgs;
      };
      moghedien = import ./hosts/moghedien.nix {
        inherit nixpkgs home-manager openconnect-sso martiert cisco webex-linux vysor;
      };
    };
  };
}
