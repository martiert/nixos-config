{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "mattrim";

  nixos = ({ config, pkgs, lib, ... }: {
    age.secrets = {
      "dropbear_key".file = ../../secrets/mattrim_dropbear_key.age;
      "hydra_keyfile".file = ../../secrets/hydra_private_key.age;
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
      kernelParams = [ "ip=dhcp" ];
      initrd = {
        availableKernelModules = [ "e1000e" ];
        network = {
          enable = true;
          udhcpc.enable = true;
          ssh = {
            enable = true;
            port = 22;
            shell = "/bin/cryptsetup-askpass";
            authorizedKeys = lib.mapAttrsToList (name: type: builtins.readFile "${toString ./public_keys}/${name}") (builtins.readDir ./public_keys);
            hostKeys = [
              config.age.secrets."dropbear_key".path
            ];
          };
        };
      };
    };
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    hardware.enableRedistributableFirmware = true;
    martiert = {
      system.type = "server";
      mountpoints = {
        root = {
          encryptedDevice = "/dev/disk/by-uuid/76fe6c3a-1d87-4078-9cc0-c0dcba6b4be5";
          device = "/dev/mapper/root";
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

    services.hydra = {
      enable = true;
      buildMachinesFiles = [];
      hydraURL = "https://hydra.martiert.com";
      notificationSender = "hydra@hydra.martiert.com";
      useSubstitutes = true;
      port = 3000;
    };
    networking.firewall.allowedTCPPorts = [ 3000 ];
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
      buildMachines = [
        {
          hostName = "home.martiert.com";
          systems = [ "x86_64-linux" "aarch64-linux" ];
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          sshUser = "hydra";
          sshKey = config.age.secrets."hydra_keyfile".path;
          maxJobs = 3;
        }
      ];
      settings.allowed-uris = [
        "github:"
      ];
    };
  });
}
