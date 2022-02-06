{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.martiert.irssi;
  authenticationType = types.submodule ({ name, ...}: {
    options = {
      name = mkOption {
        visible = false;
        default = name;
        type = types.str;
      };
      sasl = mkOption {
        default = {};
        description = "SASL authentication";
        type = types.submodule {
          options = {
            enable = mkEnableOption "Enable SASL authentication";
            username = mkOption {
              type = types.str;
              default = "";
            };
            password = mkOption {
              type = types.str;
              default = "";
            };
            mechanism = mkOption {
              type = types.enum [ "plain" "external" ];
              default = "plain";
            };
          };
        };
      };
    };
  });
  create_auth = name: data: ''
    ${name} = {
      sasl_mechanism = "${data.sasl.mechanism}";
      sasl_username = "${data.sasl.username}";
      sasl_password = "${data.sasl.password}";
    };
  '';
  authString = concatStringsSep "\n" (mapAttrsToList create_auth cfg.authentication);
in {
  options = {
    martiert.irssi = {
      enable = mkEnableOption "Enable irssi";
      nick = mkOption {
        default = "martiert";
        type = types.str;
      };
      authentication = mkOption {
        default = {};
        description = "Authentication options";
        type = types.attrsOf authenticationType;
      };
    };
  };

  imports = [
    ../secrets/irssi_auth.nix
  ];

  config = {
    programs.irssi = {
      enable = cfg.enable;
      networks = {
        libera = {
          nick = cfg.nick;
          server = {
            address = "irc.libera.chat";
            port = 6697;
            autoConnect = true;
            ssl = {
              enable = true;
              verify = true;
            };
          };
          channels = {
            nixos.autoJoin = true;
            "C++".autoJoin = true;
            curl.autoJoin = true;
            selinux.autoJoin = true;
            chromium.autoJoin = true;
          };
        };
      };
      extraConfig = ''
        chatnets = {
        '' + authString + ''
        };
        settings = {
          core = {
            real_name = "Martin Ertsås";
            user_name = "martiert";
            nick = "martiert";
          };
        };
        ignores = ( { level = "JOINS PARTS QUITS"; } );
        '';
    };
  };
}
