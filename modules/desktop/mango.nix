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
          mods = "SUPER+SHIFT";
          key = "R";
          action = "spawn_shell";
          # mangobar has no reload signal/IPC of its own (reads style.css
          # and its config once at startup), so picking up bar changes
          # means restarting the service, not just mango's reload_config.
          args = [''mmsg dispatch reload_config && systemctl --user restart mangobar.service && notify-send -a Mango -i view-refresh "Mango" "Config + bar reloaded"''];
          desc = "Reload mango config + restart mangobar";
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
          args = ["swaylock"];
          desc = "Lock screen";
        }
        {
          mods = "SUPER";
          key = "L";
          action = "spawn";
          args = ["swaylock"];
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
          args = [''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy''];
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
          mods = "CTRL+SHIFT+ALT";
          key = "H";
          action = "move_client";
          args = ["left"];
          desc = "Move window left";
        }
        {
          mods = "CTRL+SHIFT+ALT";
          key = "J";
          action = "move_client";
          args = ["down"];
          desc = "Move window down";
        }
        {
          mods = "CTRL+SHIFT+ALT";
          key = "K";
          action = "move_client";
          args = ["up"];
          desc = "Move window up";
        }
        {
          mods = "CTRL+SHIFT+ALT";
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
          mods = "ALT+SHIFT";
          key = "L";
          action = "spawn";
          args = ["mango-layout-picker"];
          desc = "Pick + preview any layout";
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

    # Every layout mango's arrange.c actually registers (src/layout/arrange.c);
    # the upstream docs page lists a "spiral" that doesn't exist - it's
    # called dwindle in the source.
    layouts = [
      {
        name = "tile";
        desc = "Master-stack, one resizable split ratio";
      }
      {
        name = "scroller";
        desc = "PaperWM-style horizontal scrolling strip";
      }
      {
        name = "grid";
        desc = "Even grid of windows";
      }
      {
        name = "monocle";
        desc = "One window fullscreen, rest hidden";
      }
      {
        name = "deck";
        desc = "Stack with the focused window on top";
      }
      {
        name = "center_tile";
        desc = "Master-stack with a centered master";
      }
      {
        name = "right_tile";
        desc = "Master-stack with master on the right";
      }
      {
        name = "vertical_scroller";
        desc = "Scroller, scrolling vertically";
      }
      {
        name = "vertical_tile";
        desc = "Tile, stacked vertically";
      }
      {
        name = "vertical_grid";
        desc = "Grid, stacked vertically";
      }
      {
        name = "vertical_deck";
        desc = "Deck, stacked vertically";
      }
      {
        name = "dwindle";
        desc = "Recursive binary-tree splits (spiral effect)";
      }
      {
        name = "fair";
        desc = "Equal space for every window";
      }
      {
        name = "vertical_fair";
        desc = "Fair, stacked vertically";
      }
    ];

    layoutsCheatsheet =
      lib.concatMapStringsSep "\n"
      (l: "${lib.fixedWidthString 20 " " l.name} ${l.desc}")
      layouts;

    # Lets you fuzzel-pick any of the 14 layouts above and immediately see
    # it applied, instead of memorizing/binding a key per layout.
    layoutPicker = pkgs.writeShellScriptBin "mango-layout-picker" ''
      set -euo pipefail
      choice=$(${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Layout> " --lines 14 --width 70 \
        < ${pkgs.writeText "mango-layouts.txt" layoutsCheatsheet})
      [ -n "$choice" ] || exit 0
      layout=$(printf '%s' "$choice" | ${pkgs.gawk}/bin/awk '{print $1}')
      mmsg dispatch setlayout,"$layout"
      notify-send -a Mango -i view-grid "Layout" "$layout"
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
      layoutPicker
      libnotify
      volumeOsd
      lswt
      mako
      pavucontrol
      playerctl
      swaybg
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
          # Indices are 0-based tag bits: 7 = tag 8 (windowrule sends
          # discord/vesktop there), 8 = tag 9 (spotify), 9 = tag 0/F10.
          tag-names = ["1" "2" "3" "4" "5" "6" "7" "󰙯" "󰓇" "0"];
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
      /* Material 3 tonal roles, mapped onto the existing warm forest
       * palette instead of swapping in Google's default purple. mangobar
       * has no box-shadow/elevation, so "elevation" here is faked with a
       * 3-step surface tonal ladder (surface < surface-container <
       * surface-container-high), and color is reserved for
       * state/actionable modules rather than sprinkled everywhere. */
      @define-color surface #171310;
      @define-color surface-container #221c16;
      @define-color surface-container-high #2e261d;
      @define-color outline #3a2f24;
      @define-color on-surface #f5e6d3;
      @define-color on-surface-variant #a8927c;

      @define-color primary #f2994a;
      @define-color on-primary #1c1410;
      @define-color primary-container #4a3420;
      @define-color on-primary-container #ffd9a8;

      @define-color secondary #6a994e;
      @define-color on-secondary #12190d;

      @define-color tertiary #f4c95d;
      @define-color on-tertiary #241a03;

      @define-color error #d9534f;
      @define-color on-error #2a0a08;

      * {
        # mangobar's CSS parser keeps only the first font-family value and
        # drops any fallback list, so this must be a font that itself
        # covers every glyph used in this config (Nerd Font icons included).
        # font-family/size/weight are also global, not per-selector, so
        # they can only be set once here.
        font-family: "Maple Mono NF";
        # M3's label-medium type-scale token (the one the spec assigns to
        # dense chip/status-bar text): 12px, medium weight.
        font-size: 12px;
        font-weight: Medium;
        color: @on-surface;
        background-color: @surface-container;
        padding: 0px 12px;
        margin: 4px 3px;
        # M3 shape-scale "corner-small" (8px) - what filter/assist chips
        # use, per the spec. Grouped pill-shaped controls (tags/overview/
        # layout below) override this with "corner-full" instead.
        border-radius: 8px;
      }

      #bar {
        background: none;
        margin: 6px 10px;
      }

      /* Tag row reads as an M3 segmented button (single-select, one
       * highlighted segment) rather than a row of chips, so it gets
       * "corner-full" - fully rounded, per the segmented-button spec. */
      #tags {
        padding: 0px 10px;
        min-width: 26px;
        border-radius: 9999px;
      }

      /* Selected tag: filled with primary, the one accent that always
       * means "current". */
      #tags.active {
        background-color: @primary;
        color: @on-primary;
      }
      /* Has windows: raised a tone above resting surface. */
      #tags.occupied {
        background-color: @surface-container-high;
        color: @on-surface;
      }
      #tags.urgent {
        background-color: @error;
        color: @on-error;
      }
      /* Empty: sunk a tone below resting surface, muted text. */
      #tags.empty {
        background-color: @surface;
        color: @on-surface-variant;
      }

      /* Distinct from the active-tag accent so it doesn't read as "tag 1
       * is active" when overview mode is toggled instead. Same pill shape
       * as #tags since it sits directly in that cluster. */
      #overview {
        background-color: @tertiary;
        color: @on-tertiary;
        border-radius: 9999px;
      }

      #layout {
        background-color: @secondary;
        color: @on-secondary;
        min-width: 28px;
        border-radius: 9999px;
      }

      #title {
        background-color: @surface-container;
        color: @on-surface-variant;
      }

      /* Interactive (click/scroll to change volume): gets a container
       * accent instead of a neutral tone. */
      #volume {
        background-color: @primary-container;
        color: @on-primary-container;
      }

      #tray {
        background-color: @surface-container;
      }

      /* Passive info, not actionable, so neutral tones rather than the
       * old solid-yellow/green fill. */
      #clock {
        background-color: @surface-container-high;
        color: @on-surface;
      }
      #clock.date {
        background-color: @surface-container;
        color: @on-surface-variant;
      }

      /* Per the M3 menu-component spec: surface-container fill,
       * "corner-extra-small" (4px) shape - menus stay closer to square
       * than the chips/pills around them. */
      menu {
        background-color: @surface-container;
        border-color: @outline;
        border-radius: 4px;
      }
      menuitem {
        color: @on-surface;
      }
      menuitem:hover {
        background-color: @primary;
        color: @on-primary;
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

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        image = wallpaperPath;
        scaling = "fill";

        # Blur is computed synchronously on the full screenshot before the
        # lock screen appears, so it's CPU-bound at lock time; effect-scale
        # downsamples first to keep that from stuttering on a 4K screen.
        effect-scale = 0.5;
        effect-blur = "5x3";
        effect-vignette = "0.5:0.5";
        fade-in = 0.2;

        clock = true;
        timestr = "%I:%M %p";
        datestr = "%a %b %d";
        font = "JetBrainsMono";
        font-size = 24;
        indicator = true;
        indicator-radius = 120;
        indicator-thickness = 10;

        color = "1c1410";
        inside-color = "1c1410CC";
        ring-color = "f2994a";
        line-color = "00000000";
        separator-color = "00000000";
        text-color = "f5e6d3";
        text-caps-lock-color = "f4c95d";

        ring-ver-color = "f4c95d";
        inside-ver-color = "1c1410CC";
        text-ver-color = "f5e6d3";

        ring-wrong-color = "BF616A";
        inside-wrong-color = "1c1410CC";
        text-wrong-color = "f5e6d3";

        ring-clear-color = "6a994e";
        inside-clear-color = "1c1410CC";
        text-clear-color = "f5e6d3";

        key-hl-color = "f2994a";
        bs-hl-color = "BF616A";
        caps-lock-key-hl-color = "f4c95d";
        caps-lock-bs-hl-color = "BF616A";

        layout-bg-color = "1c1410CC";
        layout-text-color = "f5e6d3";
      };
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
          command = "swaylock -f";
        }
        {
          timeout = 2 * 60 * 60;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = {
        # Lock before any suspend, not just ones swayidle itself triggers
        # (e.g. lid close, power button, manual `systemctl suspend`).
        before-sleep = "swaylock -f";
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
          "tags:9,appid:^Spotify$"
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
      # swaylock needs its own PAM service to authenticate against the user's
      # password; without this it rejects every attempt since it can't read
      # /etc/shadow via pam_unix.
      security.pam.services.swaylock = {};
    };
  };
}
