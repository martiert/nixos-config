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

  version = "5.3.1";

  src = fetchurl {
    url = "https://en.fss.flashforge.com/10000/software/7f8b3d7b5185be8d8d25bacb45995eda.deb";
    sha256 = "64ab30f75e0ea274693ba3dab9b78034c302388dc703d44c3b50b1baefd84127";
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
