{ cisco
, vysor
, martiert
, system
}:

self: super: {
  vysor = super.callPackage vysor {};
  teamctl = cisco.outputs.packages."${system}".teamctl;
  roomctl = cisco.outputs.packages."${system}".roomctl;
  projecteur = martiert.outputs.packages."${system}".projecteur;
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
