{ stdenv, lib, fetchFromGitHub, buildPythonPackage, git, octoprint }:

buildPythonPackage rec {
  pname = "OctoPrint-Flashforge";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "Mrnt";
    repo = pname;
    rev = version;
    hash = "sha256-kLgSkRVzsrUe/LEyeZH+NmEORk60aD9scS09//0Wc+4=";
  };

  propagatedBuildInputs = [
    octoprint
  ];

  doCheck = false;
}
