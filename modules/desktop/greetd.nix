{
  den.aspects.greetd.nixos = {
    pkgs,
    lib,
    ...
  }: let
    # Matches the warm dark palette used by mango/mangobar/mako/swaylock.
    theme = lib.concatStringsSep ";" [
      "border=#f2994a"
      "text=#f5e6d3"
      "greet=#f5e6d3"
      "input=#f5e6d3"
      "title=#f2994a"
      "prompt=#f4c95d"
      "time=#f4c95d"
      "action=#6a994e"
      "button=#6a994e"
      "container=#1c1410"
    ];

    args = lib.concatStringsSep " " [
      "--cmd mango"
      "--time"
      ''--time-format "%I:%M %p · %a %b %d"''
      ''--greeting "welcome back"''
      "--greet-align center"
      "--container-padding 2"
      "--asterisks"
      ''--theme "${theme}"''
      "--background doom"
      ''--doom-colors "#f4c95d,#f2994a,#BF616A"''
    ];
  in {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet ${args}";
        user = "greeter";
      };
    };
  };
}
