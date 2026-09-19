{den, ...}: let
  tmuxHomeManager = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
      escapeTime = 0;
      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
      ];
      # https://nix.dev/manual/nix/2.18/language/builtins.html?highlight=readFile#built-in-functions
      extraConfig = ''
        ###############################################################
        set-option -g default-terminal 'screen-256color'
        set-option -g terminal-overrides ',xterm-256color:RGB'
        ###############################################################
        set-option -g status-position top
        set-option -g status-bg default
        set-option -g status-style bg=default
        set-option -g status-left ""
        set-option -g status-right "#{session_name} "
        set-option -g window-status-current-format " #I:#W"
        set-option -g window-status-format " #I:#W"
        set-option -g window-status-current-style "fg=#CCFF0B,bold"
        set-option -g window-status-style "fg=grey"

        # Undercurl support
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

        # Set windows to start at 1
        set -g base-index 1
        setw -g pane-base-index 1

        set -g default-command "$SHELL"

        set -g prefix C-a
        unbind C-b
        bind-key C-a send-prefix

        set-option -g allow-passthrough on

        # Windows
        unbind %
        bind | split-window -h
        unbind '"'
        bind - split-window -v
        # ---

        # Create and list new windows
        unbind n # next-window
        bind n new-window
        unbind c
        bind c kill-window
        unbind l
        bind l choose-tree -Zw
        unbind ,
        unbind r
        bind-key r command-prompt -I "#W" "rename-window '%%'"
        # ---

        # Window selection
        unbind p # previous-window
        unbind l
        bind l next-window
        unbind h
        bind h previous-window
        # ---

        # Reload configuration file
        # unbind r
        # bind r source-file ~/.config/tmux/tmux.conf
        # Can't reload source if we're Nix-ing :)
        # ---

        # resize-panes
        set -g mouse on
        # bind -r j resize-pane -D 5
        # bind -r k resize-pane -U 5
        # bind -r l resize-pane -R 5
        # bind -r h resize-pane -L 5
        # bind -r m resize-pane -Z
        # ---

        # Vi-related settings
        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection
        unbind -T copy-mode-vi MouseDragEnd1Pane
        # ---

        # Pane sync / Mult-SSH Session Sync
        bind-key b set-window-option synchronize-panes\; display-message "synchronize-panes is now #{?pane_synchronized,on,off}"
        # ---

        # Equalize space
        unbind e
        bind e select-layout tiled
        # ---

        # ---
        # Theme/Feel/Look
        # https://github.com/tmux/tmux/wiki/Getting-Started#list-of-style-and-format-options
        # General Styles
        #
        # set-option -g message-style
        # set-option -g mode-style
        #
        # ---
        # PANES
        #
        # set-option -g display-panes-active-colour
        # set-option -g display-panes-color
        # set-option -g pane-active-border-style
        # set-option -g pane-border-format
        # set-option -g pane-border-style
        #
        # STATUS
        #
        # set-option -g status-style
        #
        # set-option -g status-left
        # set-option -g status-left-length-style
        # set-option -g status-left-style
        #
        # set-option -g status-right
        # set-option -g status-right-length-style
        # set-option -g status-right-style
        #
        # WINDOW
        #
        # set-option -g window-active-style
        # set-option -g window-status-current-format
        # set-option -g window-status-current-style
        # set-option -g window-status-format
        # set-option -g window-status-seperator
        # set-option -g window-status-style
        # set-option -g window-style
        # ---
      '';
    };
  };
in {
  den.aspects.tmux-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "tmux-config/${user.userName}@${host.name}";
        homeManager = tmuxHomeManager;
      })
    ];
  };
}
