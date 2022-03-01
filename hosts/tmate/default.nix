{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "tmate.martiert.com";

  nixos = ({modulesPath, pkgs, ...}: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      ./networking.nix
      ../../nixos/services/openssh.nix
    ];

    boot = {
      loader.grub.device = "/dev/vda";
      initrd.kernelModules = [ "nvme" ];
      cleanTmpDir = true;
    };
    zramSwap.enable = true;

    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };

    services.openssh.ports = [ 222 ];
    networking.firewall.allowedTCPPorts = [ 22 222 ];
    systemd.services.tmate = {
      enable = true;
      description = "tmate server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.tmate-ssh-server}/bin/tmate-ssh-server -v -k /etc/keys -p 22 -q 22";
      };
    };
    nixpkgs.config.permittedInsecurePackages = [
      "tmate-ssh-server-2.3.0"
    ];

    martiert.sshd = {
      enable = true;
      authorizedKeyFiles = [
        ./public_keys/moghedien.pub
        ./public_keys/moridin.pub
        ./public_keys/aginor.pub
        ./public_keys/perrin.pub
      ];
    };

    nix.settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "moridin.martiert.com:MpOYdKDwUz4u8UpSJGxGUR3Xj40RPJRIvDW9b0vUM6o="
      "moghedien.martiert.com:5JJbyXsIZrlivMr0UinqJ+ql6QprHcjWjDqyCsJhHJg="
      "aginor.martiert.com:ghjjAbho+lr6iyoPOxxBQWOf/bgR1ao87VLN9L4K/EU="
      "perrin.martiert.com:bdteAJqcaMttOeurDxGiPDsy3gf3q5+LaPrY/wyouOk="
    ];
  });
}
