{ lib
, mkDerivation
, fetchFromGitHub
, makeDesktopItem
, cmake
, git
, pkg-config
, qt5
}:

let
  binaryName = "projecteur";
in mkDerivation rec {
  pname = "projecteur";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "jahnf";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-kg6oYtJ4H5A6RNATBg+XvMfCb9FlhEBFjfxamGosMQg=";
  };

  nativeBuildInputs = [
    cmake
    git
    pkg-config
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtdeclarative
    qt5.qtgraphicaleffects
    qt5.qtx11extras
    qt5.qtwayland
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_UDEVRULESDIR=${placeholder "out"}/lib/udev/rules.d"
  ];

  desktopItem = makeDesktopItem {
    name = pname;
    exec = binaryName;
    icon = pname;
    desktopName = pname;
    genericName = meta.description;
  };

  meta = with lib; {
    description = "Projecteur app for Logitech Spotlight";
    homepage = "https://github.com/jahnf/Projecteur";
    downloadPage = "https://github.com/jahnf/Projecteur/releases";
    license = licenses.mit;
    maintainers = [{
      name = "Martin Ertsås";
      email = "martiert@gmail.com";
    }];
    platforms = [ "x86_64-linux" ];
  };
}
