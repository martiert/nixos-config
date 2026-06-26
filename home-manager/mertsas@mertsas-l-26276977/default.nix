{ ... }:

let
  setAuthorizedKeys = map builtins.readFile;
  map_private_keys = let
    path = ./private_keys;
  in callback: 
    builtins.listToAttrs (builtins.map (fullname: let
      name = (builtins.replaceStrings [".age"] [""] fullname);
    in {
      inherit name;
      value = (callback name path);
    }) (builtins.attrNames (builtins.readDir path)));

in {
  system = "x86_64-linux";
  config = { pkgs, lib, config, ... }: let
    setAuthorizedKeys = files: lib.strings.concatStringsSep "\n" (map builtins.readFile files);
  in {
    home.file.".ssh/authorized_keys_src" = {
      enable = true;
      text = setAuthorizedKeys [
        ./public_keys/aginor.pub
      ];

      onChange = ''
        rm -fr "$HOME/.ssh/authorized_keys"
        cat "$HOME/.ssh/authorized_keys_src" > "$HOME/.ssh/authorized_keys"
        chmod 600 "$HOME/.ssh/authorized_keys"
      '';
    };

    age = {
      identityPaths = [
        "/home/mertsas/.ssh/age/id_ed25519"
      ];
      secrets = map_private_keys (name: path: {
        file = "${path}/${name}.age";
        mode = "400";
      });
    };

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      agents = ./ai/agents;
      extraPackages = [
        pkgs.bash
      ];
    };

    martiert = {
      system.type = "desktop";
      i3.enable = true;
      terminal.fontSize = 14;
      email = {
        enable = true;
        address = "mertsas@cisco.com";
        smtp = {
          tls = false;
          host = "outbound.cisco.com:2525";
        };
        imap.tls = false;
        davmail = {
          o365 = {
            enable = true;
            clientId = "953f4ef4-80ac-48d1-b98c-f66f227bb094";
          };
        };
      };
      ssh_config = {
        enable = true;
        matchBlocks = lib.recursiveUpdate (map_private_keys (name: path: {
          identitiesOnly = true;
          identityFile = config.age.secrets."${name}".path;
          forwardAgent = false;
        })) {
          "github.com".user = "git";
          "lys-git.cisco.com".user = "git";
          "home.martiert.com" = {
            addressFamily = "inet";
            user = "martin";
          };
          "aginor.rd.cisco.com" = {
            user = "martin";
          };
          "sqbu-github.cisco.com" = {
            user = "git";
            serverAliveInterval = 60;
            serverAliveCountMax = 120;
          };
          "cebuild" = {
            hostname = "cebuild21.rd.cisco.com";
            forwardAgent = true;
            remoteForwards = [{
              host = "/run/user/1000/gnupg/S.gpg-agent.extra";
              bind = "/run/user/1650476972/gnupg/S.gpg-agent.extra";
            }];
          };
          "mertsas-bar" = {
            user = "root";
            identitiesOnly = true;
            identityFile = config.age.secrets.test_sw.path;
          };
          "mertsas-touch" = {
            user = "root";
            identitiesOnly = true;
            identityFile = config.age.secrets.test_sw.path;
          };
          "mertsas-pictoris" = {
            user = "root";
            identitiesOnly = true;
            identityFile = config.age.secrets.test_sw.path;
          };
        };
      };
    };
  };
}
