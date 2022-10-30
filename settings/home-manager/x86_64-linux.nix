{ pkgs, ...}:

{
  home.packages = with pkgs; [
    google-chrome

    zoom-us
    webex

    spotify
    steam
    flashPrint
  ];
}
