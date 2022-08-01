{ pkgs, ... }:

let
  overlay = import (builtins.fetchGit {
    url = "git@sqbu-github.cisco.com:mertsas/nix-overlay.git";
    rev = "086566d98e0ce8e75c83ca6f3a62684e6e5e1461";
    ref = "main";
  }) { inherit pkgs; };
in {
  nixpkgs.overlays = [
    overlay
  ];

  packages = [
    pkgs.teamctl
    pkgs.roomctl
    pkgs.vysor
  ];
}
