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
  tmuxp = callPackage ./tmux.nix {};

  beltsearch = beltsearch.outputs.packages."${system}".beltsearch;

  weechatScripts = {
    weechat-matrix2 = super.weechatScripts.weechat-matrix.overrideAttrs (old: rec {
      dontBuild = false;
      buildPhase = "mkdir dist";
    });
    wee-slack = super.weechatScripts.wee-slack;
  };

  tmate = super.tmate.overrideAttrs (old: rec {
    version = "2.3.0";
    src = super.fetchFromGitHub {
      owner  = "tmate-io";
      repo   = "tmate";
      rev    = "2.3.0";
      sha256 = "SocdTFLGsojBR5+AXQ24x9P97dD8JHImRtfJcGeFmDs=";
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
