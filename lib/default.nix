{ nixpkgs ? import <nixpkgs> {}
, lib ? nixpkgs.lib}:

let
  isNixFile = {name, type}: type == "directory" || lib.strings.hasSuffix ".nix" name;
  nixFiles = folder:
    let
      content = builtins.readDir folder;
      contentList = lib.mapAttrsToList (name: type: { inherit name type;}) content;
    in
    builtins.filter isNixFile contentList;

  hosts = builtins.map (x: x.name) (nixFiles ../hosts);
in rec {
  forEachEntry = func: entries:
    lib.listToAttrs (builtins.map (entry: { name = "${entry.name}"; value = func entry; }) entries);

  forAllNixHosts = func:
    let
      content = builtins.map (name: {
        name = name;
        value = func name ../hosts/${name};
      }) hosts;
    in
      lib.listToAttrs content;
}
