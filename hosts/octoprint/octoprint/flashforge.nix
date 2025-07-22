{ stdenv, lib, fetchFromGitHub, buildPythonPackage, setuptools, git, octoprint, libusb1 }:

buildPythonPackage rec {
  pname = "OctoPrint-Flashforge";
  version = "0.2.6";
  pyproject = true;
  build-system = [ setuptools ];

  src = fetchFromGitHub {
    owner = "Mrnt";
    repo = pname;
    rev = version;
    hash = "sha256-kLgSkRVzsrUe/LEyeZH+NmEORk60aD9scS09//0Wc+4=";
  };

  propagatedBuildInputs = [
    octoprint
    libusb1
  ];

  doCheck = false;
}
