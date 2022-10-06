{ pkgs, ... }:

let
  weechatSetup = pkgs.weechat.override {
    configure = { availablePlugins, ... }: {
      scripts = with pkgs.weechatScripts; [
        weechat-matrix2
        wee-slack
      ];
    };
  };
in {
  home.packages = [
    weechatSetup
  ];
}
