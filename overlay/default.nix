{ nixpkgs
, cisco
, vysor
, martiert
, system
}:

let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs.libsForQt5) callPackage;
in self: super: {
  vysor = super.callPackage vysor {};
  teamctl = cisco.outputs.packages."${system}".teamctl;
  roomctl = cisco.outputs.packages."${system}".roomctl;
  projecteur = callPackage ./projecteur.nix { };
  mutt-ics = martiert.outputs.packages."${system}".mutt-ics;
  generate_ssh_key = martiert.outputs.packages."${system}".generate_ssh_key;

  tmate = super.tmate.overrideAttrs (old: rec {
    version = "2.3.0";
    src = super.fetchFromGitHub {
      owner  = "tmate-io";
      repo   = "tmate";
      rev    = "2.3.0";
      sha256 = "SocdTFLGsojBR5+AXQ24x9P97dD8JHImRtfJcGeFmDs=";
    };
  });
}
