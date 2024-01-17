{ nixpkgs
, system
}:

let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs.libsForQt5) callPackage;
in self: super: {
  tmuxp = callPackage ./tmuxp.nix { tmuxp = super.tmuxp; };
}
