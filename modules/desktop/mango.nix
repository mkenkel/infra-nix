{
  den,
  inputs,
  ...
}: let
  mangoHomeManager = {
    config,
    pkgs,
    ...
  }: let
    wallpaperPath = "${config.home.homeDirectory}/.config/wallpapers/default.png";
  in {
    imports = [
      inputs.mango.hmModules.mango
      inputs.mangobar.homeManagerModules.default
    ];
    home.packages = with pkgs; [
      fuzzel
      glib
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
        bind = [
          "SUPER,F,togglefullscreen"
          "SUPER,T,togglefloating"
          "SUPER,Q,killclient"
          "ALT,Q,killclient"
          "SUPER,R,reload_config"
          "CTRL+ALT+SHIFT,E,quit"

          "ALT,Return,spawn,kitty"
          "ALT,D,spawn,fuzzel"
          "ALT,Escape,spawn,${pkgs.swaylock-effects}/bin/swaylock"
          "ALT+SHIFT,P,spawn,pavucontrol"
          "ALT+SHIFT,S,spawn_shell,${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
          "ALT+SHIFT,X,spawn,mylock"
          "SUPER,O,spawn,swaync-client -t"

          "SUPER,J,focusstack,next"
          "SUPER,K,focusstack,prev"
          "ALT,N,exchange_stack_client,next"
          "ALT,P,exchange_stack_client,prev"
          "SUPER+ALT,H,move_client,left"
          "SUPER+ALT,J,move_client,down"
          "SUPER+ALT,K,move_client,up"
          "SUPER+ALT,L,move_client,right"
          "SUPER+ALT+SHIFT,H,resizewin,-100,0"
          "SUPER+ALT+SHIFT,J,resizewin,0,100"
          "SUPER+ALT+SHIFT,K,resizewin,0,-100"
          "SUPER+ALT+SHIFT,L,resizewin,100,0"

          "SUPER,Space,focusmon,next"
          "SUPER,Period,focusmon,next"
          "SUPER+CTRL,Space,focusmon,prev"
          "SUPER+SHIFT,Space,tagmon,next,1"
          "SUPER+SHIFT,Period,tagmon,next,1"
          "SUPER+SHIFT,Comma,tagmon,prev,1"

          "NONE,F1,view,1"
          "NONE,F2,view,2"
          "NONE,F3,view,3"
          "NONE,F4,view,4"
          "NONE,F5,view,5"
          "NONE,F6,view,6"
          "NONE,F7,view,7"
          "NONE,F8,view,8"
          "NONE,F9,view,9"
          "NONE,F10,view,0"
          "SHIFT,F1,tag,1"
          "SHIFT,F2,tag,2"
          "SHIFT,F3,tag,3"
          "SHIFT,F4,tag,4"
          "SHIFT,F5,tag,5"
          "SHIFT,F6,tag,6"
          "SHIFT,F7,tag,7"
          "SHIFT,F8,tag,8"
          "SHIFT,F9,tag,9"
          "SHIFT,F10,toggletag,0"

          "CTRL+ALT,H,setmfact,-0.025"
          "CTRL+ALT,L,setmfact,+0.025"
          "ALT+SHIFT,J,incnmaster,-1"
          "ALT+SHIFT,K,incnmaster,+1"
          "ALT,H,setlayout,tile"
          "ALT,J,setlayout,dwindle"
          "ALT,K,setlayout,scroller"
          "ALT,L,switch_layout"
          "ALT,W,switch_layout"

          "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%+"
          "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%-"
          "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SINK@ toggle"
          "SHIFT,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SOURCE@ toggle"
          "NONE,XF86AudioPlay,spawn,playerctl play-pause"
          "NONE,XF86AudioNext,spawn,playerctl next"
          "NONE,XF86AudioPrev,spawn,playerctl previous"
        ];
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
