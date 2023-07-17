{ lib, config, ...}:

let
  tmuxp_config = {
    session_name = "work";
    windows = [
      {
        window_name = "1:CE";
        layout = "even-horizontal";
        shell_command_before = [
          "cd Cisco/main/main"
        ];
        panes = [
          "vim"
          {
            focus = true;
          }
        ];
      }
      {
        window_name = "2:weechat";
        panes = [
          "weechat"
        ];
      }
      {
        window_name = "3:mutt";
        panes = [
          "neomutt"
        ];
      }
      {
        window_name = "4:os";
        layout = "even-horizontal";
        shell_command_before = [
          "cd Cisco/os/os"
        ];
        panes = [
          "vim"
          {
            focus = true;
          }
        ];
      }
      {
        window_name = "5:training";
        layout = "even-horizontal";
        shell_command_before = [
          "cd Cisco/training"
        ];
        panes = [
          "vim"
          {
            focus = true;
          }
        ];
      }
    ];
  };
in lib.mkIf (config.martiert.system.type != "server") {
  programs.tmux = {
    tmuxp.enable = true;
    enable = true;
    keyMode = "vi";
    historyLimit = 20000;
    baseIndex = 1;
    extraConfig = ''
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      set -g status-justify centre

      set -g status-bg black

      set -g status-left-length 30
      set -g status-left '#[fg=green][ #W ]['
      set -g status-right '#[fg=green]][#[fg=blue] %Y-%m-%d#[fg=white] %H:%M:%S#[fg=green]#[fg=cyan] (#(hostname))#[fg=green] ]'
      set -g status-right-length 40

      set-window-option -g automatic-rename off
      set-window-option -g window-status-format '#{?window_bell_flag,#[fg=red],#[fg=white]}#W'
      set-window-option -g window-status-current-format '#[fg=cyan]#W'
      set-window-option -g pane-base-index 1
      set-window-option -g automatic-rename off

      set-option -g allow-rename off
    '';
  };

  xdg.configFile."tmuxp/work.json".text = builtins.toJSON tmuxp_config;
}
