{inputs, ...}: let
  # See lib/monitors.nix - same shared monitor layout mango/river/grub
  # read, formatted for mango's own config syntax (no spaces around "="
  # here, matching how this raw text block already reads below).
  monitor = builtins.head (import ../../lib/monitors.nix);
  monitorRuleLine = "monitorrule=name:^${monitor.name}$,width:${toString monitor.width},height:${toString monitor.height},refresh:${toString monitor.refresh},scale:${toString monitor.scale},x:${toString monitor.x},y:${toString monitor.y}";
in {
  den.aspects.greetd.nixos = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [inputs.dank-greeter.nixosModules.dank-greeter];

    # dms-greeter only picks up wallpaper/theme from real DankMaterialShell
    # state files (it copies configFiles verbatim into its cache dir at
    # login, keyed off exact filenames like session.json). We don't run the
    # full DMS shell, so this hand-writes just enough of session.json to
    # reuse the same wallpaper as swaylock/mango.
    environment.etc."dms-greeter/session.json".text = builtins.toJSON {
      wallpaperPath = "/home/matt/.config/wallpapers/forest.jpg";
      wallpaperFillMode = "PreserveAspectCrop";
    };

    # mango has no cursor-theme config key of its own; it (like the real
    # session) just reads XCURSOR_THEME/XCURSOR_SIZE from the environment.
    # greetd execs the greeter directly (no login shell/PAM env sourcing
    # yet), so the theme has to come from the greetd unit's own env, and the
    # theme package has to be visible system-wide since the greeter user
    # doesn't have matt's home-manager profile.
    environment.systemPackages = [pkgs.posy-cursors];
    systemd.services.greetd.environment = {
      XCURSOR_THEME = "Posy_Cursor_125_175";
      XCURSOR_SIZE = "48";
    };

    services.greetd.settings.default_session.user = "greeter";

    programs.dms-greeter = {
      enable = true;
      compositor.name = "mango";
      configFiles = ["/etc/dms-greeter/session.json"];

      # dms-greeter runs mango standalone (outside the home-manager mango
      # session), so it starts from mango's packaged default config rather
      # than ~/.config/mango/config.conf. Base off that same default and
      # layer on the real monitor/refresh-rate rule and cursor size so the
      # greeter matches the actual session instead of falling back to 60Hz.
      compositor.customConfig =
        builtins.readFile "${config.programs.mango.package}/etc/mango/config.conf"
        + ''

          # dms-greeter overrides: match the real session's monitor/cursor setup
          ${monitorRuleLine}
          cursor_size=48
        '';
    };
  };
}
