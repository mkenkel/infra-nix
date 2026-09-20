{
  den,
  ...
}: let
  riverHomeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    wallpaperPath = "${config.home.homeDirectory}/.config/wallpapers/forest.jpg";
  in {
    home.packages = with pkgs; [
      cliphist
      fuzzel
      glib
      grim
      kitty
      libnotify
      lswt
      mako
      pavucontrol
      river-classic
      rivercarro
      slurp
      vicinae
      waybar
      wayland-pipewire-idle-inhibit
      wl-clipboard
      wlr-randr
    ];

    # NIXOS_OZONE_WL/QT_QPA_PLATFORM/SDL_VIDEODRIVER are already set
    # identically by the mango aspect. XDG_CURRENT_DESKTOP/XDG_SESSION_DESKTOP
    # are intentionally *not* set as static home.sessionVariables here (that
    # would conflict with mango's "mango" value) — river's own
    # systemd.extraCommands below sets them dynamically for the actual
    # running session instead.

    services.mako.enable = true;

    # `programs.swaylock` / `services.swayidle` are single global
    # home-manager options already owned by the mango aspect (den.aspects.mango);
    # river's own lock/idle keybinds just spawn the shared `swaylock` binary,
    # which picks up that same generated config regardless of which
    # compositor is active. Not redeclared here to avoid conflicting
    # definitions between the two aspects.

    # Not a home-manager service module upstream; wire it up manually so it
    # actually inhibits idle (via idle-inhibit-unstable-v1) while media plays,
    # instead of just sitting installed and unused. Named uniquely (rather
    # than reusing mango's unit name) since mango's copy is PartOf
    # mango-session.target and wouldn't start under a river session.
    systemd.user.services.river-wayland-pipewire-idle-inhibit = {
      Unit = {
        Description = "Suspend idling while media plays through PipeWire";
        PartOf = ["river-session.target"];
        After = ["river-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit";
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = ["river-session.target"];
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 40;
          spacing = 5;
          output = ["DP-3"];
          modules-left = ["river/tags" "pulseaudio"];
          modules-center = ["clock"];
          modules-right = ["tray"];

          "river/tags" = {
            num-tags = 9;
          };

          tray = {
            spacing = 10;
            icon-size = 20;
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰖁 {volume}%";
            format-icons = {
              default = ["󰕿" "󰖀" "󰕾"];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };

          clock = {
            format = "{:%I:%M %p}";
            format-alt = "{:%A, %B %d, %Y - %I:%M %p}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              format = {
                months = "<span color='#fad07a'><b>{}</b></span>";
                days = "<span color='#e8e8d3'>{}</span>";
                today = "<span color='#cf6a4c'><b><u>{}</u></b></span>";
              };
            };
          };
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 5px;
          font-family: Source Code Pro;
        }
        window#waybar {
          background: transparent;
          color: #e8e8d3;
        }
        #tags {
          background: #151515;
          border: 1px solid #1f1f1f;
          margin: 5px;
          padding: 2px;
        }
        #tags button {
          padding: 0 5px;
          color: #888888;
          border-radius: 3px;
        }
        #tags button.occupied {
          background: #1f1f1f;
          color: #e8e8d3;
        }
        #tags button.focused {
          background: #597bc5;
          color: #151515;
        }
        #tray {
          background: #151515;
          border: 1px solid #1f1f1f;
          padding: 0 10px;
          margin: 5px;
          color: #e8e8d3;
        }
        #pulseaudio {
          background: #151515;
          border: 1px solid #1f1f1f;
          padding: 0 10px;
          margin: 5px;
          color: #99ad6a;
        }
        #clock {
          background: #151515;
          border: 1px solid #1f1f1f;
          padding: 0 10px;
          margin: 5px;
          color: #8fbfdc;
        }
      '';
    };

    wayland.windowManager.river = {
      enable = true;
      systemd.enable = true;
      systemd.variables = [
        "DISPLAY"
        "GDK_BACKEND,wayland"
        "NIXOS_OZONE_WL,1"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "SDL_VIDEODRIVER,wayland"
        "WAYLAND_DISPLAY"
        "XCURSOR_SIZE"
        "XCURSOR_THEME"
        "XDG_CURRENT_DESKTOP,river"
        "XDG_SESSION_DESKTOP,river"
        "XDG_SESSION_TYPE,wayland"
      ];
      systemd.extraCommands = [
        "systemctl --user stop river-session.target"
        "systemctl --user start river-session.target"
        "dbus-update-activation-environment --systemd --all"
        "systemctl --user set-environment XDG_CURRENT_DESKTOP=river"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.rivercarro}/bin/rivercarro -inner-gaps 3 -outer-gaps 3 -no-smart-gaps -per-tag -main-ratio 0.63"
      ];
      extraConfig = ''
        riverctl spawn "${pkgs.wlr-randr}/bin/wlr-randr --output DP-3 --mode 3840x2160@143.962997Hz --scale 1.25"
      '';
      settings = {
        declare-mode = ["locked" "normal" "passthrough"];
        attach-mode = "top";
        background-color = "0x0b0e0d";
        border-color-unfocused = "0xfafef9";
        border-color-focused = "0x007bc0";
        border-color-urgent = "0xf75f59";
        border-width = 2;
        default-layout = "rivercarro";
        input = {
          pointer-foo-bar = {
            accel-profile = "flat";
            events = true;
            pointer-accel = -0.3;
            tap = false;
          };
        };
        map = {
          normal = {
            "Alt+Shift X" = "spawn '${pkgs.swaylock-effects}/bin/swaylock -f'";
            "Alt+Shift S" = "spawn '${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
            "Super F" = "toggle-fullscreen";
            "Super J" = "focus-view next";
            "Super K" = "focus-view previous";
            "Super O" = "spawn '${pkgs.mako}/bin/makoctl mode -t dnd'";
            "Super Period" = "focus-output next";
            "Super Q" = "close";
            "Super Space" = "focus-output next";
            "Super T" = "toggle-float";
            "Alt Escape" = "spawn '${pkgs.swaylock-effects}/bin/swaylock -f'";
            "Super Tab" = "spawn '${pkgs.mako}/bin/makoctl dismiss -a'";
            "Super+Alt H" = "move left 100";
            "Super+Alt J" = "move down 100";
            "Super+Alt K" = "move up 100";
            "Super+Alt L" = "move right 100";
            "Super+Alt+Shift H" = "resize horizontal -100";
            "Super+Alt+Shift J" = "resize vertical 100";
            "Super+Alt+Shift K" = "resize vertical -100";
            "Super+Alt+Shift L" = "resize horizontal 100";
            "Super+Control Space" = "focus-output previous";
            "Super+Control+Shift Space" = "send-to-output previous";

            "None F1" = "set-focused-tags 1";
            "None F2" = "set-focused-tags 2";
            "None F3" = "set-focused-tags 4";
            "None F4" = "set-focused-tags 8";
            "None F5" = "set-focused-tags 16";
            "None F6" = "set-focused-tags 32";
            "None F7" = "set-focused-tags 64";
            "None F8" = "set-focused-tags 128";
            "None F9" = "set-focused-tags 256";
            "None F10" = "set-focused-tags 2147483647";

            "Shift F1" = "set-view-tags 1";
            "Shift F2" = "set-view-tags 2";
            "Shift F3" = "set-view-tags 4";
            "Shift F4" = "set-view-tags 8";
            "Shift F5" = "set-view-tags 16";
            "Shift F6" = "set-view-tags 32";
            "Shift F7" = "set-view-tags 64";
            "Shift F8" = "set-view-tags 128";
            "Shift F9" = "set-view-tags 256";
            "Shift F10" = "set-view-tags 2147483647";

            "Super+Shift Comma" = "send-to-output previous";
            "Super+Shift Period" = "send-to-output next";
            "Super+Shift Space" = "send-to-output next";

            "Control+Alt H" = "send-layout-cmd rivercarro 'main-ratio -0.025'";
            "Control+Alt L" = "send-layout-cmd rivercarro 'main-ratio +0.025'";

            "Alt N" = "swap next";
            "Alt P" = "swap previous";
            "Alt+Shift K" = "send-layout-cmd rivercarro 'main-count +1'";
            "Alt+Shift J" = "send-layout-cmd rivercarro 'main-count -1'";

            "Alt K" = "send-layout-cmd rivercarro 'main-location top'";
            "Alt L" = "send-layout-cmd rivercarro 'main-location right'";
            "Alt J" = "send-layout-cmd rivercarro 'main-location bottom'";
            "Alt H" = "send-layout-cmd rivercarro 'main-location left'";
            "Alt M" = "send-layout-cmd rivercarro 'main-location monocle'";
            "Alt W" = "send-layout-cmd rivercarro 'main-location-cycle left,monocle'";
            "Alt Shift H" = "spawn 'pkill fuzzel || ${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel --no-fuzzy --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy'";

            "Control+Alt+Shift E" = "exit";
            "Alt D" = "spawn '${pkgs.fuzzel}/bin/fuzzel'";
            "Alt Shift P" = "spawn '${pkgs.pavucontrol}/bin/pavucontrol'";
            "Alt Q" = "close";
            "Alt Return" = "spawn '${pkgs.kitty}/bin/kitty'";
          };
        };

        rule-add = {
          "-app-id" = {
            "'waybar'" = "ssd";
            "'org.pulseaudio.pavucontrol'" = "float";
            "'firefox'" = "ssd";
            "'steam'" = "ssd";
          };
        };
        set-cursor-warp = "on-output-change";
        focus-follows-cursor = "normal";
        set-repeat = "50 300";
        spawn = [
          "pkill waybar; waybar &"
          "pkill swaybg; ${pkgs.swaybg}/bin/swaybg -i ${wallpaperPath} -m fill &"
        ];
        xcursor-theme = "Posy_Cursor_125_175 45";
      };
    };
  };
in {
  den.aspects.river = {
    homeManager = riverHomeManager;
    nixos = {
      programs.river-classic.enable = true;
      # swaylock needs its own PAM service to authenticate against the user's
      # password; without this it rejects every attempt since it can't read
      # /etc/shadow via pam_unix.
      security.pam.services.swaylock = {};
    };
  };
}
