{
  den.aspects.greetd.nixos = {pkgs, ...}: {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd mango";
        user = "greeter";
      };
    };
  };
}
