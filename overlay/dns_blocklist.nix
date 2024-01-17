{ stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation {
  pname = "blocklist";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "dd039598aa0a30edf3e350e50fd1c3f08badf335";
    hash = "sha256-KLNg6bgns86Qg/oPEui+q3QpR99c+cG9S50xiXdqnu8=";
  };

  configPhase = true;
  buildPhase = "";
  installPhase = ''
    mkdir $out
    cp unbound/* $out/
  '';
}
