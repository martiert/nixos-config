{ pkgs, stdenv, lib, fetchurl }:

stdenv.mkDerivation {
  pname = "generate_ssh_key";
  version = "1.0.0";
  src = ./generate_ssh_key;

  buildInputs = with pkgs; [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      cryptography
    ]))
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p "$out/bin"
    cp $src $out/bin/$pname
    chmod +x $out/bin/$pname
  '';

  meta = with lib; {
    description = "Script to generate ssh keys";
    homepage = "https://home.martiert.com";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [{
      name = "Martin Ertsås";
      email = "martiert@gmail.com";
    }];
  };
}
