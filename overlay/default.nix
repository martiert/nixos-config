{ nixpkgs
, vysor
, blocklist
, system
}:

let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs.libsForQt5) callPackage;
in self: super: {
  vysor = super.callPackage vysor {};

  mutt-ics = callPackage ./mutt-ics.nix {};
  flashPrint = callPackage ./flashPrint.nix {};

  dns_blocklist = super.stdenv.mkDerivation {
    pname = "blocklist";
    version = "1.0.0";

    src = blocklist;

    configPhase = true;
    buildPhase = "";
    installPhase = ''
      mkdir $out
      cp -r * $out/
    '';
  };
  tmuxp = self.callPackage ./tmuxp.nix { tmuxp = super.tmuxp; };
}
