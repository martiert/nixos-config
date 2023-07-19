{ nixpkgs
, cisco
, vysor
, beltsearch
, blocklist
, system
}:

let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs.libsForQt5) callPackage;
in self: super: {
  vysor = super.callPackage vysor {};
  teamctl = cisco.outputs.packages."${system}".teamctl;
  roomctl = cisco.outputs.packages."${system}".roomctl;

  mutt-ics = callPackage ./mutt-ics.nix {};
  flashPrint = callPackage ./flashPrint.nix {};

  beltsearch = beltsearch.outputs.packages."${system}".beltsearch;

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
}
