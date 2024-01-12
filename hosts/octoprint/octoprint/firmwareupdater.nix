{ buildPythonPackage, octoprint, fetchFromGitHub, ... }:

let
  name = "FirmwareUpdater";
in buildPythonPackage rec {
  pname = "OctoPrintPlugin-${name}";
  version = "1.14.0";
  propagatedBuildInputs = [
    octoprint
  ];

  src = fetchFromGitHub {
    owner = "OctoPrint";
    repo = "OctoPrint-${name}";
    rev = version;
    hash = "sha256-CUNjM/IJJS/lqccZ2B0mDOzv3k8AgmDreA/X9wNJ7iY=";
  };

  doCheck = false;
}
