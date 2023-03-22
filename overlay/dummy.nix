self: super: {
  generate_ssh_key = super.callPackage ./generate_ssh_key {};
} // (
let
  useSystemApplicationFor = application: {
    name = application;
    value = super.writeShellScriptBin application ''
      exec /usr/bin/${application}
    '';
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
