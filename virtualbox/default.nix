{ pkgs, ... }:

{
  system.stateVersion = "23.05";
  environment.variables.EDITOR = "vim";
  networking.hostName = "virtualbox";
  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
  };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ./aginor.pub
    ];
  };
  services.openssh = {
    enable = true;
  };
}
