{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
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
    vysor = {
      url = "git+ssh://git@sqbu-github.cisco.com/CE/vysor";
      flake = false;
    };
    beltsearch.url = "git+ssh://git@sqbu-github.cisco.com/mertsas/beltsearch?ref=main";
    blocklist = {
      url = "github:notracking/hosts-blocklists";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, flake-utils, agenix, home-manager, nixos-generators, deploy-rs, cisco, vysor, beltsearch, blocklist, ... }@inputs:
    let
      lib = nixpkgs.lib.extend(self: super: (import ./lib) { 
        inherit nixpkgs nixos-wsl home-manager agenix cisco vysor beltsearch blocklist;
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

      homeConfigurations.martin = home-manager.lib.homeManagerConfiguration rec {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          overlays = [
            (import ./overlay/dummy.nix)
          ];
        };
        modules = [
          {
            home.stateVersion = "23.05";
            home.username = "martin";
            home.homeDirectory = "/home/martin";

            programs.zsh.initExtra = ". /home/martin/.nix-profile/etc/profile.d/nix.sh";

            xsession.windowManager.i3.config = {
              startup = [
                { command = "alacritty"; }
                { command = "firefox"; }
              ];
              workspaceOutputAssign = [
                {
                  output = "eDP-1";
                  workspace = "1";
                }
              ];
              assigns = {
                "2" = [{ class = "^firefox$"; }];
              };
            };
            wayland.windowManager.sway.config = {
              startup = [
                { command = "alacritty"; }
                { command = "firefox"; }
              ];
              workspaceOutputAssign = [
                {
                  output = "eDP-1";
                  workspace = "1";
                }
              ];
              assigns = {
                "2" = [{ app_id = "^firefox$"; }];
              };
            };
            martiert = {
              i3status = {
                enable = true;
                networks = {
                  wireless = [
                    "wlan0"
                  ];
                  ethernet = [
                    "enu1u2"
                  ];
                };
              };
              i3 = {
                enable = true;
              };
            };

            imports = [
              ./settings/home-manager/all.nix
            ];
          }
        ];
      };
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
           # aarch64-installer = nixos-generators.nixosGenerate {
           #   pkgs = import nixpkgs { system = "aarch64-linux"; };
           #   modules = [
           #     ./tools/aarch64-installer
           #   ];
           #   format = "install-iso";
           # };

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
