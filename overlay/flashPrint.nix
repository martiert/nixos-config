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
    url = "https://en.fss.flashforge.com/10000/software/269af4512c7abc085e964644a2b744f3.deb";
    sha256 = "1a51753a314d702ca525521a1074277dffbd5524d4e9476c3474415da5f30b88";
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
