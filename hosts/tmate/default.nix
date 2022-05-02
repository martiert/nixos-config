{ nixpkgs, ... }:

{
  system = "x86_64-linux";
  deployTo = "tmate.martiert.com";

  nixos = ({modulesPath, pkgs, ...}: {
    imports = [
      "${modulesPath}/profiles/qemu-guest.nix"
      ./networking.nix
      ../../settings/nixos/services/openssh.nix
      ../../machines/nixos-cache.nix
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
  });
}
