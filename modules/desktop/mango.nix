{
  den,
  inputs,
  ...
}: let
  mangoHomeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    wallpaperPath = "${config.home.homeDirectory}/.config/wallpapers/forest.jpg";

    # Declarative keybind list: single source of truth for both the mango
    # `bind` config and the fuzzel keybindings cheatsheet below.
    keybinds =
      [
        {
          mods = "SUPER";
          key = "F";
          action = "togglefullscreen";
          desc = "Toggle fullscreen";
        }
        {
          mods = "SUPER";
          key = "T";
          action = "togglefloating";
          desc = "Toggle floating";
        }
        {
          mods = "SUPER";
          key = "Q";
          action = "killclient";
          desc = "Close focused window";
        }
        {
          mods = "ALT";
          key = "Q";
          action = "killclient";
          desc = "Close focused window";
        }
        {
          mods = "SUPER";
          key = "R";
          action = "spawn_shell";
          args = [''mmsg dispatch reload_config && notify-send -a Mango -i view-refresh "Mango" "Config reloaded"''];
          desc = "Reload mango config";
        }
        {
          mods = "CTRL+ALT+SHIFT";
          key = "E";
          action = "quit";
          desc = "Quit mango";
        }

        {
          mods = "ALT";
          key = "Return";
          action = "spawn";
          args = ["kitty"];
          desc = "Launch terminal";
        }
        {
          mods = "ALT";
          key = "D";
          action = "spawn";
          args = ["fuzzel"];
          desc = "Launch app launcher";
        }
        {
          mods = "ALT";
          key = "Slash";
          action = "spawn";
          args = ["mango-keybinds-menu"];
          desc = "Show this keybindings cheatsheet";
        }
        {
          mods = "ALT";
          key = "Escape";
          action = "spawn";
          args = ["${pkgs.swaylock-effects}/bin/swaylock"];
          desc = "Lock screen";
        }
        {
          mods = "SUPER";
          key = "L";
          action = "spawn";
          args = ["${pkgs.swaylock-effects}/bin/swaylock"];
          desc = "Lock screen";
        }
        {
          mods = "ALT+SHIFT";
          key = "P";
          action = "spawn";
          args = ["pavucontrol"];
          desc = "Open volume mixer";
        }
        {
          mods = "ALT+SHIFT";
          key = "S";
          action = "spawn_shell";
          args = [''${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy''];
          desc = "Screenshot region to clipboard";
        }
        {
          mods = "ALT+CTRL";
          key = "S";
          action = "spawn_shell";
          args = ["${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy"];
          desc = "Screenshot full screen to clipboard";
        }
        {
          mods = "SUPER";
          key = "O";
          action = "spawn";
          args = ["swaync-client -t"];
          desc = "Toggle notification center";
        }

        {
          mods = "SUPER";
          key = "J";
          action = "focusstack";
          args = ["next"];
          desc = "Focus next window in stack";
        }
        {
          mods = "SUPER";
          key = "K";
          action = "focusstack";
          args = ["prev"];
          desc = "Focus previous window in stack";
        }
        {
          mods = "ALT";
          key = "Tab";
          action = "focusstack";
          args = ["next"];
          desc = "Cycle to next window";
        }
        {
          mods = "ALT+SHIFT";
          key = "Tab";
          action = "focusstack";
          args = ["prev"];
          desc = "Cycle to previous window";
        }
        {
          mods = "ALT";
          key = "N";
          action = "exchange_stack_client";
          args = ["next"];
          desc = "Swap with next stack client";
        }
        {
          mods = "ALT";
          key = "P";
          action = "exchange_stack_client";
          args = ["prev"];
          desc = "Swap with previous stack client";
        }
        {
          mods = "SUPER+ALT";
          key = "H";
          action = "move_client";
          args = ["left"];
          desc = "Move window left";
        }
        {
          mods = "SUPER+ALT";
          key = "J";
          action = "move_client";
          args = ["down"];
          desc = "Move window down";
        }
        {
          mods = "SUPER+ALT";
          key = "K";
          action = "move_client";
          args = ["up"];
          desc = "Move window up";
        }
        {
          mods = "SUPER+ALT";
          key = "L";
          action = "move_client";
          args = ["right"];
          desc = "Move window right";
        }
        {
          mods = "SUPER+ALT+SHIFT";
          key = "H";
          action = "resizewin";
          args = ["-100" "0"];
          desc = "Shrink window width";
        }
        {
          mods = "SUPER+ALT+SHIFT";
          key = "J";
          action = "resizewin";
          args = ["0" "100"];
          desc = "Grow window height";
        }
        {
          mods = "SUPER+ALT+SHIFT";
          key = "K";
          action = "resizewin";
          args = ["0" "-100"];
          desc = "Shrink window height";
        }
        {
          mods = "SUPER+ALT+SHIFT";
          key = "L";
          action = "resizewin";
          args = ["100" "0"];
          desc = "Grow window width";
        }

        {
          mods = "SUPER";
          key = "Space";
          action = "focusmon";
          args = ["next"];
          desc = "Focus next monitor";
        }
        {
          mods = "SUPER";
          key = "Period";
          action = "focusmon";
          args = ["next"];
          desc = "Focus next monitor";
        }
        {
          mods = "SUPER+CTRL";
          key = "Space";
          action = "focusmon";
          args = ["prev"];
          desc = "Focus previous monitor";
        }
        {
          mods = "SUPER+SHIFT";
          key = "Space";
          action = "tagmon";
          args = ["next" "1"];
          desc = "Send tag to next monitor";
        }
        {
          mods = "SUPER+SHIFT";
          key = "Period";
          action = "tagmon";
          args = ["next" "1"];
          desc = "Send tag to next monitor";
        }
        {
          mods = "SUPER+SHIFT";
          key = "Comma";
          action = "tagmon";
          args = ["prev" "1"];
          desc = "Send tag to previous monitor";
        }
      ]
      ++ (lib.concatMap (n: [
          {
            mods = "NONE";
            key = "F${toString n}";
            action = "view";
            args = [(toString n)];
            desc = "Switch to tag ${toString n}";
          }
          {
            mods = "SHIFT";
            key = "F${toString n}";
            action = "tag";
            args = [(toString n)];
            desc = "Move window to tag ${toString n}";
          }
        ])
        (lib.range 1 9))
      ++ [
        {
          mods = "NONE";
          key = "F10";
          action = "view";
          args = ["0"];
          desc = "Switch to tag 0";
        }
        {
          mods = "SHIFT";
          key = "F10";
          action = "toggletag";
          args = ["0"];
          desc = "Toggle tag 0 on window";
        }

        {
          mods = "CTRL+ALT";
          key = "H";
          action = "setmfact";
          args = ["-0.025"];
          desc = "Shrink master area";
        }
        {
          mods = "CTRL+ALT";
          key = "L";
          action = "setmfact";
          args = ["+0.025"];
          desc = "Grow master area";
        }
        {
          mods = "ALT+SHIFT";
          key = "J";
          action = "incnmaster";
          args = ["-1"];
          desc = "Decrease master count";
        }
        {
          mods = "ALT+SHIFT";
          key = "K";
          action = "incnmaster";
          args = ["+1"];
          desc = "Increase master count";
        }
        {
          mods = "ALT";
          key = "H";
          action = "setlayout";
          args = ["tile"];
          desc = "Set layout: tile";
        }
        {
          mods = "ALT";
          key = "J";
          action = "setlayout";
          args = ["dwindle"];
          desc = "Set layout: dwindle";
        }
        {
          mods = "ALT";
          key = "K";
          action = "setlayout";
          args = ["scroller"];
          desc = "Set layout: scroller";
        }
        {
          mods = "ALT";
          key = "L";
          action = "switch_layout";
          desc = "Cycle layout";
        }
        {
          mods = "ALT";
          key = "W";
          action = "switch_layout";
          desc = "Cycle layout";
        }

        {
          mods = "NONE";
          key = "XF86AudioRaiseVolume";
          action = "spawn";
          args = ["volume-osd up sink"];
          desc = "Volume up";
        }
        {
          mods = "NONE";
          key = "XF86AudioLowerVolume";
          action = "spawn";
          args = ["volume-osd down sink"];
          desc = "Volume down";
        }
        {
          mods = "NONE";
          key = "XF86AudioMute";
          action = "spawn";
          args = ["volume-osd mute sink"];
          desc = "Mute output";
        }
        {
          mods = "SHIFT";
          key = "XF86AudioMute";
          action = "spawn";
          args = ["volume-osd mute source"];
          desc = "Mute microphone";
        }
        {
          mods = "SUPER";
          key = "Up";
          action = "spawn";
          args = ["volume-osd up sink"];
          desc = "Volume up";
        }
        {
          mods = "SUPER";
          key = "Down";
          action = "spawn";
          args = ["volume-osd down sink"];
          desc = "Volume down";
        }
        {
          mods = "SUPER";
          key = "M";
          action = "spawn";
          args = ["volume-osd mute sink"];
          desc = "Mute output";
        }
        {
          mods = "NONE";
          key = "XF86AudioPlay";
          action = "spawn";
          args = ["playerctl play-pause"];
          desc = "Play/pause media";
        }
        {
          mods = "NONE";
          key = "XF86AudioNext";
          action = "spawn";
          args = ["playerctl next"];
          desc = "Next media track";
        }
        {
          mods = "NONE";
          key = "XF86AudioPrev";
          action = "spawn";
          args = ["playerctl previous"];
          desc = "Previous media track";
        }
        {
          mods = "NONE";
          key = "XF86MonBrightnessUp";
          action = "spawn";
          args = ["brightnessctl set 5%+"];
          desc = "Brightness up";
        }
        {
          mods = "NONE";
          key = "XF86MonBrightnessDown";
          action = "spawn";
          args = ["brightnessctl set 5%-"];
          desc = "Brightness down";
        }
      ];

    bindString = b: lib.concatStringsSep "," ([b.mods b.key b.action] ++ (b.args or []));

    # Friendlier key names for the cheatsheet display only.
    keyDisplay = key:
      {
        Return = "Enter";
        Escape = "Esc";
        Period = ".";
        Comma = ",";
        Slash = "/";
      }
      .${
        key
      } or key;

    comboDisplay = b:
      if b.mods == "NONE"
      then keyDisplay b.key
      else "${b.mods}+${keyDisplay b.key}";

    keybindsCheatsheet =
      lib.concatMapStringsSep "\n"
      (b: "${lib.fixedWidthString 24 " " (comboDisplay b)} ${b.desc}")
      keybinds;

    keybindsMenu = pkgs.writeShellScriptBin "mango-keybinds-menu" ''
      ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Keybinds> " --lines 20 --width 90 \
        < ${pkgs.writeText "mango-keybinds.txt" keybindsCheatsheet} \
        | ${pkgs.gawk}/bin/awk '{$1=$1; NF=NF}1' \
        | ${pkgs.wl-clipboard}/bin/wl-copy
    '';

    # Adjusts/mutes the default sink or source, then pops a mako progress-bar
    # OSD reflecting the resulting level. The x-canonical-private-synchronous
    # hint makes mako replace the previous "volume" toast instead of stacking.
    volumeOsd = pkgs.writeShellScriptBin "volume-osd" ''
      set -euo pipefail

      device="@DEFAULT_SINK@"
      tag="volume"
      label="Volume"
      if [ "''${2:-}" = "source" ]; then
        device="@DEFAULT_SOURCE@"
        tag="mic"
        label="Microphone"
      fi

      case "''${1:-}" in
        up) wpctl set-volume "$device" 5%+ ;;
        down) wpctl set-volume "$device" 5%- ;;
        mute) wpctl set-mute "$device" toggle ;;
      esac

      status=$(wpctl get-volume "$device")
      percent=$(echo "$status" | awk '{printf "%.0f", $2 * 100}')

      if echo "$status" | grep -q MUTED; then
        notify-send -a "$label" -i audio-volume-muted \
          -h "int:value:$percent" -h "string:x-canonical-private-synchronous:$tag" \
          "$label muted"
      else
        icon="audio-volume-high"
        [ "$percent" -lt 66 ] && icon="audio-volume-medium"
        [ "$percent" -lt 33 ] && icon="audio-volume-low"
        notify-send -a "$label" -i "$icon" \
          -h "int:value:$percent" -h "string:x-canonical-private-synchronous:$tag" \
          "$label $percent%"
      fi
    '';
  in {
    imports = [
      inputs.mango.hmModules.mango
      inputs.mangobar.homeManagerModules.default
    ];
    home.packages = with pkgs; [
      brightnessctl
      fuzzel
      glib
      keybindsMenu
      libnotify
      volumeOsd
      lswt
      mako
      pavucontrol
      playerctl
      swaybg
      swaylock-effects
      swaynotificationcenter
      vicinae
      wayland-pipewire-idle-inhibit
      wl-clipboard
    ];

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XDG_CURRENT_DESKTOP = "mango";
      XDG_SESSION_DESKTOP = "mango";
      XDG_SESSION_TYPE = "wayland";
    };

    services.mako = {
      enable = true;
      settings = {
        background-color = "#000000CC";
        border-radius = 5;
        border-size = 5;
        default-timeout = 8000;
        font = "JetBrainsMono 12";
        format = "<sup><i>%a</i></sup>\\n<b>%s</b>\\n<sub>%b</sub>";
        height = 300;
        icon-location = "right";
        icons = 1;
        ignore-timeout = 1;
        layer = "overlay";
        max-icon-size = 128;
        max-visible = 5;
        outer-margin = 30;
        sort = "-time";
        text-alignment = "center";
        width = 450;

        # Low urgency: shorter timeout
        "urgency=low".default-timeout = 3;

        # Urgent notifications should stand out and stay until dismissed
        "urgency=critical" = {
          background-color = "#BF616A";
          text-color = "#ECEFF4";
          border-color = "#D08770";
          default-timeout = 0;
          format = "<b>%a — %s</b>\\n%b";
        };

        # Spotify / music notifications: clearer layout, persist while playing
        "app-name=Spotify" = {
          layer = "overlay";
          history = 0;
          default-timeout = 8000;
          border-color = "#1DB954";
          background-color = "#191414";
        };

        # Volume/mic OSD: compact pill anchored bottom-center with a progress
        # bar driven by the "value" hint set in the volume-osd script.
        "app-name=Volume" = {
          anchor = "bottom-center";
          outer-margin = 60;
          width = 280;
          height = 70;
          history = 0;
          layer = "overlay";
          default-timeout = 1200;
          border-color = "#f2994a";
          background-color = "#1c1410E6";
          progress-color = "over #f2994a";
          text-alignment = "center";
          format = "<b>%s</b>";
        };
        "app-name=Microphone" = {
          anchor = "bottom-center";
          outer-margin = 60;
          width = 280;
          height = 70;
          history = 0;
          layer = "overlay";
          default-timeout = 1200;
          border-color = "#6a994e";
          background-color = "#1c1410E6";
          progress-color = "over #6a994e";
          text-alignment = "center";
          format = "<b>%s</b>";
        };
      };
    };
    wayland.systemd.target = "mango-session.target";

    services.mangobar = {
      enable = true;
      systemdTarget = "mango-session.target";
      settings = {
        layer = "top";
        height = 36;
        buffer-scale = 1;

        modules-left = ["workspaces" "layout" "window"];
        modules-center = ["clock#date" "clock#time"];
        modules-right = ["pulseaudio" "tray"];

        workspaces = {
          hide-empty = false;
          overview-label = "OVERVIEW";
          on-click = "activate";
          on-click-right = "toggle";
        };

        layout.format = "{}";

        window.format = "{}";

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 {volume}%";
          icons = ["󰕿" "󰖀" "󰕾"];
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_SINK@ 5%-";
        };

        "clock#date".format = " {:L%b %d · %A}";
        "clock#time".format = " {:L%I:%M %p}";

        tray = {
          icon-size = 20;
          spacing = 10;
        };
      };
    };

    xdg.configFile."mangobar/style.css".text = ''
      * {
        font-family: Source Code Pro;
        color: #f5e6d3;
        background-color: #1c1410;
        padding: 0px 10px;
        margin: 5px 2px;
        border-radius: 6px;
      }

      #bar {
        background: none;
        margin: 5px 8px;
      }

      #tags {
        padding: 0px 8px;
      }

      #tags.active {
        background-color: #f2994a;
        color: #1c1410;
      }
      #tags.occupied {
        background-color: #2a201a;
        color: #f5e6d3;
      }
      #tags.urgent {
        background-color: #d9534f;
        color: #1c1410;
      }
      #tags.empty {
        background-color: #151009;
        color: #7a6a5a;
      }

      #overview {
        background-color: #f2994a;
        color: #1c1410;
      }

      #layout {
        background-color: #6a994e;
        color: #151009;
        min-width: 28px;
      }

      #title {
        background-color: #2a201a;
        color: #f5e6d3;
      }

      #volume {
        background-color: #f4c95d;
        color: #1c1410;
      }

      #tray {
        background-color: #2a201a;
      }

      #clock {
        background-color: #f4c95d;
        color: #1c1410;
      }
      #clock.date {
        background-color: #6a994e;
        color: #151009;
      }

      menu {
        background-color: #151009;
        border-color: #f5e6d3;
        border-radius: 8px;
      }
      menuitem {
        color: #f5e6d3;
      }
      menuitem:hover {
        background-color: #f2994a;
        color: #1c1410;
      }
    '';

    systemd.user.services.spotify-notify = {
      Unit = {
        Description = "Desktop notifications for Spotify track changes";
        PartOf = ["mango-session.target"];
        After = ["mango-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "spotify-notify" ''
          art_cache="''${XDG_CACHE_HOME:-$HOME/.cache}/spotify-notify"
          mkdir -p "$art_cache"

          while true; do
            ${pkgs.playerctl}/bin/playerctl --player=spotify --follow metadata --format '{{title}}|{{artist}}|{{mpris:artUrl}}' 2>/dev/null \
              | while IFS='|' read -r title artist art_url; do
                  icon="spotify"
                  case "$art_url" in
                    file://*)
                      icon="''${art_url#file://}"
                      ;;
                    http://*|https://*)
                      dest="$art_cache/$(echo "$art_url" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d' ' -f1).jpg"
                      if [ ! -s "$dest" ]; then
                        ${pkgs.curl}/bin/curl -sfL "$art_url" -o "$dest" || rm -f "$dest"
                      fi
                      [ -s "$dest" ] && icon="$dest"
                      ;;
                  esac
                  ${pkgs.libnotify}/bin/notify-send -a Spotify -i "$icon" "$title" "$artist"
                done
            sleep 2
          done
        ''}";
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = ["mango-session.target"];
    };

    services.wlsunset = {
      enable = true;
      latitude = 39.1;
      longitude = -84.6;
      temperature = {
        day = 6500;
        night = 4000;
      };
    };

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 30 * 60;
          command = "${pkgs.swaylock-effects}/bin/swaylock -f";
        }
        {
          timeout = 2 * 60 * 60;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = {
        # Lock before any suspend, not just ones swayidle itself triggers
        # (e.g. lid close, power button, manual `systemctl suspend`).
        before-sleep = "${pkgs.swaylock-effects}/bin/swaylock -f";
      };
    };

    # Not a home-manager service module upstream; wire it up manually so it
    # actually inhibits idle (via idle-inhibit-unstable-v1) while media plays,
    # instead of just sitting installed and unused.
    systemd.user.services.wayland-pipewire-idle-inhibit = {
      Unit = {
        Description = "Suspend idling while media plays through PipeWire";
        PartOf = ["mango-session.target"];
        After = ["mango-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit";
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = ["mango-session.target"];
    };

    wayland.windowManager.mango = {
      enable = true;
      autostart_sh = ''
        if [ -f "${wallpaperPath}" ]; then
          swaybg -i "${wallpaperPath}" -m fill &
        fi
      '';
      settings = {
        monitorrule = [
          "name:^DP-3$,width:3840,height:2160,refresh:143.962997,scale:1.25,x:0,y:0"
        ];
        repeat_rate = 40;
        repeat_delay = 200;

        # Notification/OSD popups (mako) are layer-shell surfaces, so they
        # fade in/out via layer_animations rather than the window animation
        # toggle, which is left off to avoid animating every tiled window.
        layer_animations = 1;
        layer_animation_type_open = "fade";
        layer_animation_type_close = "fade";
        animation_duration_open = 180;
        animation_duration_close = 150;
        animation_curve_open = "0.46,1.0,0.29,1";
        animation_curve_close = "0.46,1.0,0.29,1";

        windowrule = [
          "isfloating:1,appid:pavucontrol"
          "isfloating:1,appid:qalculate-qt"
          "tags:8,appid:^(discord|vesktop)$"
          "tags:9,appid:spotify"
        ];

        bind = map bindString keybinds;
      };
    };
  };
in {
  den.aspects.mango = {
    homeManager = mangoHomeManager;
    nixos = {
      imports = [inputs.mango.nixosModules.mango];
      programs.mango.enable = true;
    };
  };
}
