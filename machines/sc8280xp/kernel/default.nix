{ pkgs, buildLinux, ... }@args:

let
  steev_kernel_pkg = { buildLinux, ... }@args:
   buildLinux (args // rec {
     version = "6.3.7";
     modDirVersion = version;
     # defconfig = ./defconfig;
     defconfig = "laptop_defconfig";

     src = pkgs.fetchFromGitHub {
       owner = "steev";
       repo = "linux";
       rev = "f5e2f5acce9b6b56eb2e0f83f3a66506d2a0e761";
       sha256 = "RE/hMMoI3KdnzKXkpKZcSS7doz6KFqjeyoD7BOnCvC8=";
     };
     kernelPatches = [
       {
         name = "Add firmware";
         patch = ./add_firmware.patch;
         extraConfig = "";
       }
     ];
   } // (args.argsOverride or {}));
  steev_kernel = pkgs.callPackage steev_kernel_pkg {};
in
  pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor steev_kernel)
