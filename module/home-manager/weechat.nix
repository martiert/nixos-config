{ pkgs, lib, config, ... }:

let
  weechatSetup = pkgs.weechat.override {
    configure = { availablePlugins, ... }: {
      scripts = with pkgs.weechatScripts; [
        weechat-matrix
        wee-slack
      ];
    };
  };
in lib.mkIf (config.martiert.system.type != "server") {
  home.packages = [
    weechatSetup
  ];
}
