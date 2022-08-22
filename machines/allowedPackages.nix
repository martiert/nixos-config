{ lib, ...}:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "cnijfilter2"
    "google-chrome"
    "skypeforlinux"
    "steam"
    "steam-original"
    "steam-runtime"
    "webex"
    "teamctl"
    "roomctl"
    "Oracle_VM_VirtualBox_Extension_Pack"
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
    "spotify"
    "spotify-unwrapped"
    "zoom"
    "teamviewer"
  ];
}
