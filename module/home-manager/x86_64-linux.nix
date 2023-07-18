{ pkgs, lib, config, ...}:

lib.mkIf (pkgs.system == "x86_64-linux" && config.martiert.system.type != "server") {
  home.packages = with pkgs; [
    google-chrome

    zoom-us
    webex

    spotify
    steam
    flashPrint
  ];
}
