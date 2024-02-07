{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "hydra";

  nixos = ({ modulesPath, pkgs, config, ... }: {
    imports = [
      "${toString modulesPath}/virtualisation/virtualbox-image.nix"
    ];

    martiert = {
      system = {
        type = "server";
      };
      networking.interfaces = {
        "enp0s3" = {
          enable = true;
          useDHCP = true;
        };
      };
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/aginor.pub
        ];
      };
    };

    age.secrets."hydra_keyfile".file = ../../secrets/hydra_private_key.age;
    services.hydra = {
      enable = true;
      buildMachinesFiles = [];
      hydraURL = "http://0.0.0.0:3000";
      notificationSender = "hydra@localhost";
      useSubstitutes = true;
    };
    networking.firewall.allowedTCPPorts = [ 3000 ];

    nix = {
      buildMachines = [
        {
          hostName = "hydra-worker1";
          system = "x86_64-linux";
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          sshUser = "martin";
          sshKey = config.age.secrets."hydra_keyfile".path;
          maxJobs = 3;
        }
      ];
      settings.allowed-uris = [
        "github:"
        "git+ssh://sqbu-github.cisco.com/"
        "git+https://sqbu-github.cisco.com/"
      ];
      package = pkgs.nixUnstable;
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
    };
  });
}
