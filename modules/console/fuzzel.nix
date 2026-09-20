{den, ...}: let
  # See lib/palette-m3.nix for the shared M3 palette this reads from
  # (also used by mango/mangobar, so the whole desktop stays in sync).
  palette = import ../../lib/palette-m3.nix;
  fuzzelHomeManager = {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "auto";
          use-bold = "yes";
          match-mode = "fzf";
          show-actions = "yes";
          terminal = "kitty";
          width = 30;
        };
        colors = {
          background = "${palette.surface}ff";
          text = "${palette.onSurface}ff";
          match = "${palette.primary}ff";
          selection = "${palette.surfaceContainerHigh}ff";
          selection-text = "${palette.onSurface}ff";
          selection-match = "${palette.primary}ff";
          border = "${palette.outline}ff";
        };
        border.width = 1;
        # M3 "corner-medium" (12px), matching mangobar's menu popup - same
        # shape language for every popup-style surface on the desktop.
        border.radius = 12;
      };
    };
  };
in {
  den.aspects.fuzzel = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "fuzzel/${user.userName}@${host.name}";
        homeManager = fuzzelHomeManager;
      })
    ];
  };
}
