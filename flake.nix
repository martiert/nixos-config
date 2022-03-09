{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
    cisco = {
      url = "git+ssh://git@sqbu-github.cisco.com/mertsas/nix-overlay?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    webex-linux.url = "git+ssh://git@sqbu-github.cisco.com/Nix/webex-linux-nix?ref=main";
    openconnect-sso = {
      url = "github:vlaci/openconnect-sso";
      flake = false;
    };
    vysor = {
      url = "git+ssh://git@sqbu-github.cisco.com/CE/vysor";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, agenix, home-manager, nixos-generators, deploy-rs, openconnect-sso, cisco, webex-linux, vysor, ... }@inputs:
    let
      lib = nixpkgs.lib.extend(self: super: (import ./lib) { 
        inherit nixpkgs home-manager agenix openconnect-sso cisco webex-linux vysor;
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
      deploy.nodes = 
        lib.forNixHostsWhere
          (config: builtins.hasAttr "deployTo" config)
          mkDeploy;

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    }
    // flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      {
        packages = {
           usbinstaller = nixos-generators.nixosGenerate {
             pkgs = import nixpkgs { inherit system; };
             modules = [
               ./tools/usbinstaller
             ];
             format = "install-iso";
           };
           digitalOcean = nixos-generators.nixosGenerate {
             pkgs = import nixpkgs { inherit system; };
             modules = [
               ./tools/digitalOcean
             ];
             format = "do";
           };
         };
       });
}
