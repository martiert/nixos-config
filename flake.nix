{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
    martiert = {
      url = "github:martiert/nix-overlay";
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

  outputs = { self, nixpkgs, flake-utils, home-manager, nixos-generators, deploy-rs, openconnect-sso, martiert, cisco, webex-linux, vysor, ... }@inputs:
    let
      lib = nixpkgs.lib.extend(self: super: (import ./lib) { lib = super; });

      mkHost = name: filename:
        let
          config = import filename {
            inherit nixpkgs home-manager openconnect-sso martiert cisco webex-linux vysor;
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
              environment.variables.EDITOR = "vim";
              environment.variables.MOZ_ENABLE_WAYLAND = "1";

              networking.hostName = name;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          ];
        };
      deployments = [ "octoprint" "pihole" ];
    in {
      nixosConfigurations = lib.forAllNixHosts mkHost;
      deploy.nodes = 
        let
          nodeSetup = name: {
            hostname = "${name}.localdomain";
            profiles.system = {
              sshUser = "root";
              path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations."${name}";
              user = "root";
            };
          };
        in 
          lib.runForEach deployments nodeSetup;
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    }
    // flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" "i686-linux" ] (system:
      {
        packages = {
           usbinstaller = nixos-generators.nixosGenerate {
             pkgs = import nixpkgs { inherit system; };
             modules = [
               ./tools/usbinstaller
             ];
             format = "install-iso";
           };
         };
       })
    // flake-utils.lib.eachDefaultSystem (system:
      {
        packages =
          let
            pkgs = import nixpkgs { inherit system; };
            deploy = deploy_name: pkgs.writeShellScriptBin "deploy" ''
                LOCAL_KEY=/etc/keys/binarycache-priv.pem ${deploy-rs.packages.${system}.deploy-rs}/bin/deploy .#${deploy_name}
              '';
          in 
            lib.runForEach deployments deploy;

        apps = 
          let
            deploy = deploy_name: {
              type = "app";
              program = "${self.packages.${system}.${deploy_name}}/bin/deploy";
            };
          in 
            lib.runForEach deployments deploy;
        });
}
