{ stdenvNoCC, pkgs, lib, fetchFromGitHub }:

let
  ath11k-firmware = stdenvNoCC.mkDerivation rec {
    pname = "ath11k-firmware";
    version = "40983a677d14c0fc21fbb808666336047f40a541";

    src = fetchFromGitHub {
      owner = "kvalo";
      repo = pname;
      rev = version;
      sha256 = "vf2QIpOWw5RqrXtDjiIZXu9uK9CTHe+pxXp9yUliGFs=";
    };

    dontFixup = true;
    dontBuild = true;

    installPhase = ''
      for i in board-2.bin regdb.bin;
      do
        install -D -m644 WCN6855/hw2.0/$i $out/$i
      done
    '';
  };

  aarch64-firmware = stdenvNoCC.mkDerivation rec {
    pname = "aarch64-firmware";
    version = "9f07579ee64aba56419cfd0fbbca9f26741edc90";

    src = fetchFromGitHub {
      owner = "linux-surface";
      repo = pname;
      rev = version;
      sha256 = "Lyav0RtoowocrhC7Q2Y72ogHhgFuFli+c/us/Mu/Ugc=";
    };

    dontFixup = true;
    dontBuild = true;

    installPhase = ''
      for i in amss.bin board-2.bin m3.bin regdb.bin;
      do
        install -D -m644 firmware/ath11k/WCN6855/hw2.0/$i $out/lib/firmware/ath11k/WCN6855/hw2.0/$i
        install -D -m644 firmware/ath11k/WCN6855/hw2.0/$i $out/lib/firmware/ath11k/WCN6855/hw2.1/$i
      done

      for i in a680_gmu.bin a680_sqe.fw a690_gmu.bin a690_sqe.fw;
      do
        install -D -m644 firmware/qcom/$i $out/lib/firmware/qcom/$i
      done

      install -D -m644 firmware/qca/hpnv21.b8c $out/lib/firmware/qca/hpnv21.b8c
    '';
  };
  cenunix-firmware = stdenvNoCC.mkDerivation rec {
    pname = "cenunix-firmware";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "cenunix";
      repo = "x13s-firmware";
      rev = "bffa30b8a4b8b5a23e2b7d312be6994af14db9c4";
      sha256 = "9rsXkmuVdoMBYmtrdp0MVZFPgJQDWJZo/awJ43c21Yo=";
    };

    dontFixup = true;
    dontBuild = true;

    installPhase = ''
      for i in qcvss8280.mbn SC8280XP-LENOVO-X13S-tplg.bin;
      do
        install -D -m644 $i $out/$i
      done
    '';
  };

in {
  linux-firmware-modified = stdenvNoCC.mkDerivation rec {
    pname = "linux-firmware-modified";
    version = pkgs.linux-firmware.version;

    dontFixup = true;
    dontBuild = true;

    src = pkgs.linux-firmware;

    installPhase = ''
      mkdir $out
      cp -Pr lib $out/lib

      # Add stuff for wifi to work
      for i in board-2.bin regdb.bin;
      do
        install -D -m644 "${ath11k-firmware}/$i" $out/lib/firmware/ath11k/WCN6855/hw2.0/$i
      done
      for i in amss.bin m3.bin;
      do
        install -D -m644 "${aarch64-firmware}/lib/firmware/ath11k/WCN6855/hw2.0/$i" $out/lib/firmware/ath11k/WCN6855/hw2.0/$i
      done

      # Add stuff for GPU to work
      for i in a680_gmu.bin a680_sqe.fw a690_gmu.bin a690_sqe.fw;
      do
        install -D -m644 "${aarch64-firmware}/lib/firmware/qcom/$i" $out/lib/firmware/qcom/$i
      done

      install -D -m644 "${aarch64-firmware}/lib/firmware/qca/hpnv21.b8c" $out/lib/firmware/qca/hpnv21.b8c
      install -D -m644 "${cenunix-firmware}/qcvss8280.mbn" $out/lib/firmware/qcom/sc8280xp/LENOVO/21BX/qcvss8280.mbn
      install -D -m644 "${cenunix-firmware}/SC8280XP-LENOVO-X13S-tplg.bin" $out/lib/firmware/qcom/sc8280xp/SC8280XP-LENOVO-X13S-tplg.bin
    '';
  };
}
