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
    keybinds = [
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
        action = "reload_config";
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
        mods = "SUPER";
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
        args = ["wpctl set-volume @DEFAULT_SINK@ 5%+"];
        desc = "Volume up";
      }
      {
        mods = "NONE";
        key = "XF86AudioLowerVolume";
        action = "spawn";
        args = ["wpctl set-volume @DEFAULT_SINK@ 5%-"];
        desc = "Volume down";
      }
      {
        mods = "NONE";
        key = "XF86AudioMute";
        action = "spawn";
        args = ["wpctl set-mute @DEFAULT_SINK@ toggle"];
        desc = "Mute output";
      }
      {
        mods = "SHIFT";
        key = "XF86AudioMute";
        action = "spawn";
        args = ["wpctl set-mute @DEFAULT_SOURCE@ toggle"];
        desc = "Mute microphone";
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
      .${key} or key;

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

    services.mako.enable = true;
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
          while true; do
            ${pkgs.playerctl}/bin/playerctl --player=spotify --follow metadata --format '{{title}}|{{artist}}' 2>/dev/null \
              | while IFS='|' read -r title artist; do
                  ${pkgs.libnotify}/bin/notify-send -a Spotify -i spotify "$title" "$artist"
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
