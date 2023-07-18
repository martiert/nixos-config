{ lib, config, ...}:

lib.mkIf (config.martiert.system.type != "server") {
  programs.git = {
    enable = true;
    userName = "Martin Ertsås";
    userEmail = "martiert@gmail.com";
    signing = {
      signByDefault = true;
      key = null;
    };
    ignores = [
      "TODO"
      "compile_commands.json"
      "shell.nix"
      ".envrc"
      ".ccls-cache"
    ];
    lfs = {
      enable = true;
      skipSmudge = true;
    };
    extraConfig = {
      diff = {
        renames = true;
        submodules = "log";
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      grep = {
        lineNumbers = true;
      };
      color = {
        status = "auto";
        branch = "auto";
        diff = "auto";
        ui = "auto";
      };
      push = {
        default = "simple";
      };
    };
    includes = [
      {
        condition = "gitdir:~/Cisco/";
        contents = {
          user = {
            email = "mertsas@cisco.com";
          };
        };
      }
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}
