{ pkgs, ... }:

let
  weechatSetup = pkgs.weechat.override {
    configure = { availablePlugins, ... }: {
      scripts = with pkgs.weechatScripts; [
        weechat-matrix
      ];
    };
  };
in {
  home.packages = [
    weechatSetup
  ];
}
