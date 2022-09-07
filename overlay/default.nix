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

  projecteur = callPackage ./projecteur.nix {};
  mutt-ics = callPackage ./mutt-ics.nix {};
  generate_ssh_key = callPackage ./generate_ssh_key {};
  flashPrint = callPackage ./flashPrint.nix {};

  beltsearch = beltsearch.outputs.packages."${system}".beltsearch;
  fido2luks = super.fido2luks.overrideAttrs (old: rec {
    meta.broken = false;
  });

  tmate = super.tmate.overrideAttrs (old: rec {
    version = "2.3.0";
    src = super.fetchFromGitHub {
      owner  = "tmate-io";
      repo   = "tmate";
      rev    = "2.3.0";
      sha256 = "SocdTFLGsojBR5+AXQ24x9P97dD8JHImRtfJcGeFmDs=";
    };
  });
  cryptsetup = super.cryptsetup.overrideAttrs (old: rec {
    pname = "cryptsetup";
    version = "2.4.3";
    src = builtins.fetchurl {
      url = "mirror://kernel/linux/utils/cryptsetup/v2.4/${pname}-${version}.tar.xz";
      sha256 = "sha256-/A35RRiBciZOxb8dC9oIJk+tyKP4VtR+upHzH+NUtQc=";
    };
  });

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
