{den, inputs, ...}: let
  mangoHomeManager = {
    config,
    pkgs,
    ...
  }: let
    wallpaperPath = "${config.home.homeDirectory}/.config/wallpapers/default.png";
  in {
    imports = [inputs.mango.hmModules.mango];
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
      waybar
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

    programs.waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        spacing = 5;
        output = ["DP-3"];
        modules-left = [
          "wlr/workspaces"
          "pulseaudio"
        ];
        modules-center = ["clock"];
        modules-right = ["tray"];

        "wlr/workspaces" = {
          format = "{name}";
          all-outputs = false;
        };

        tray = {
          spacing = 10;
          icon-size = 20;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 {volume}%";
          format-icons.default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
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
        #workspaces {
          background: #151515;
          border: 1px solid #1f1f1f;
          margin: 5px;
          padding: 2px;
        }
        #workspaces button {
          padding: 0 5px;
          color: #888888;
          border-radius: 3px;
        }
        #workspaces button.active {
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

    wayland.windowManager.mango = {
      enable = true;
      autostart_sh = ''
        if [ -f "${wallpaperPath}" ]; then
          swaybg -i "${wallpaperPath}" -m fill &
        fi
        waybar &
      '';
      settings = {
        monitorrule = [
          "name:^DP-3$,width:3840,height:2160,refresh:143.962997,scale:1.25,x:0,y:0"
        ];
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
