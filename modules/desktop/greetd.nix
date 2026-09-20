{inputs, ...}: {
  den.aspects.greetd.nixos = {...}: {
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

    services.greetd.settings.default_session.user = "greeter";

    programs.dms-greeter = {
      enable = true;
      compositor.name = "mango";
      configFiles = ["/etc/dms-greeter/session.json"];
    };
  };
}
