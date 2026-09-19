{den, ...}: let
  kittyHomeManager = {pkgs, ...}: {
    programs.kitty = {
      enable = true;
      font = {
        name = "Maple Mono NF";
        size = 16;
        package = pkgs."maple-mono".NF;
      };
      themeFile = "Jellybeans";
      settings = {
        window_border_width = 1;
        window_padding_width = 5;
        window_margin_width = 1;

        enable_audio_bell = true;
        visual_bell_duration = 0.0;
        visual_bell_color = "none";
        window_alert_on_bell = true;
        bell_on_tab = "🔔 ";
        command_on_bell = "none";

        cursor_trail = "10";
        cursor_trail_start_threshold = "0";
        shell_integration = "no-cursor";
        cursor_trail_decay = "0.01 0.15";
        cursor_shape = "block";
        cursor_blink = "true";
      };
    };
  };
in {
  den.aspects.kitty = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "kitty/${user.userName}@${host.name}";
        homeManager = kittyHomeManager;
      })
    ];
  };
}
