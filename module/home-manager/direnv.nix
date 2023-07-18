{ lib, config, ...}:

lib.mkIf (config.martiert.system.type != "server") {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
