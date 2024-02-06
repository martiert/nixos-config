self: super: {
  generate_ssh_key = super.callPackage ./generate_ssh_key {};
  webex = super.writeShellScriptBin "webex" ''
    exec /opt/Webex/bin/CiscoCollabHost
  '';
} // (
let
  useSystemApplicationFor = application: 
  let
    runscript = super.writeShellScriptBin application ''
      exec /usr/bin/${application}
    '';
  in {
    name = application;
    value = super.stdenv.mkDerivation {
      name = application;
      version = super."${application}".version;

      src = ./.;

      buildPhase = ''
        cp --recursive ${runscript}/bin bin
      '';
      installPhase = ''
        mkdir $out
        cp --recursive bin $out/bin
      '';
    };
  };
  useSystemApplications = names:
    builtins.listToAttrs (builtins.map useSystemApplicationFor names);
in useSystemApplications [
  "i3status"
  "i3bar"
  "i3lock"

  "swaylock"
  "swaybar"

  "alacritty"
  "firefox"
])
