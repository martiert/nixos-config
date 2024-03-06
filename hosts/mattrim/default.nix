{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "mattrim.localdomain";

  nixos = ({ config, pkgs, lib, ... }: {
    age.secrets = {
      hydra_keyfile = {
        file = ../../secrets/hydra_private_key.age;
        owner = "hydra-queue-runner";
      };
      hydra_signing_key = {
        file = ../../secrets/hydra_signing_key.age;
        group = "hydra";
        mode = "440";
      };
    };
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
        };
      };
      kernelPackages = pkgs.linuxPackages_latest;
    };
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    hardware.enableRedistributableFirmware = true;
    martiert = {
      system.type = "server";
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/76fe6c3a-1d87-4078-9cc0-c0dcba6b4be5";
          useTpm2Device = true;
        };
        boot = "/dev/disk/by-uuid/98E4-83D6";
      };
      sshd = {
        enable = true;
        authorizedKeyFiles = [
          ./public_keys/schnappi.pub
          ./public_keys/perrin.pub
        ];
      };
      networking.interfaces.eno1 = {
        enable = true;
        useDHCP = true;
      };
    };

    networking.resolvconf.extraConfig = ''
      name_servers='192.168.1.1'
    '';

    services.hydra = {
      enable = true;
      hydraURL = "https://hydra.martiert.com";
      notificationSender = "hydra@hydra.martiert.com";
      useSubstitutes = true;
      port = 3000;
      extraConfig = ''
        store_uri = daemon?secret-key=${config.age.secrets.hydra_signing_key.path}
      '';
    };
    networking.firewall.allowedTCPPorts = [ 3000 ];
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
        secret-key-files = ${config.age.secrets.hydra_signing_key.path}
      '';
      buildMachines = [
        {
          hostName = "home.martiert.com";
          systems = [ "x86_64-linux" "aarch64-linux" ];
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          sshUser = "hydra";
          sshKey = config.age.secrets."hydra_keyfile".path;
          maxJobs = 3;
          speedFactor = 4;
        }
        {
          hostName = "hydra-rpi-builder.localdomain";
          systems = [ "aarch64-linux" ];
          sshUser = "martin";
          sshKey = config.age.secrets."hydra_keyfile".path;
          maxJobs = 3;
          speedFactor = 1;
        }

      ];
      settings.allowed-uris = [
        "github:"
      ];
    };
  });
}
