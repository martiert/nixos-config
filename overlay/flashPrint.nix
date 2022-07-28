{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, dpkg
, qt5
, libGLU
, libGL
, glibc
, udev
}:

stdenv.mkDerivation rec {
  name = "flashPrint";

  version = "5.3.4";

  src = fetchurl {
    url = "https://en.fss.flashforge.com/10000/software/381b6e81ee43825019157b657839885b.deb";
    sha256 = "f65f0fe3cd1148f2b900a3e729d2787cc1a7844423bf38e20d0362370db697b7";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    qt5.wrapQtAppsHook
    dpkg
  ];

  buildInputs = [
    libGLU
    libGL
    udev
    glibc
    qt5.qtbase
  ];

  unpackPhase = "true";

  buildPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    mkdir --parent $out/bin
    cp --recursive usr $out/
    cp --recursive etc $out/
    ln --symbolic $out/usr/share/FlashPrint5/FlashPrint $out/bin/FlashPrint
    sed -i "/^Exec=/ c Exec=$out/bin/FlashPrint" $out/usr/share/applications/FlashPrint5.desktop
  '';
}
