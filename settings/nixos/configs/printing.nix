{ pkgs, lib, ... }:

{
  services.printing = lib.mkIf (pkgs.system == "x86_64-linux") {
    enable = true;
    drivers = [ pkgs.cnijfilter2 ];
  };
}
