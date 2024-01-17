{ nixpkgs
, system
}:

let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs.libsForQt5) callPackage;
in self: super: {
  mutt-ics = callPackage ./mutt-ics.nix {};
  flashPrint = callPackage ./flashPrint.nix {};
  dns_blocklist = callPackage ./dns_blocklist.nix {};
  tmuxp = callPackage ./tmuxp.nix { tmuxp = super.tmuxp; };
}
