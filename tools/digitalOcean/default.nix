{ pkgs, ... }:

{
  virtualisation.digitalOcean = {
    setRootPassword = true;
    setSshKeys = false;
  };
  services.openssh.passwordAuthentication = true;
}
