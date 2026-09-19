{den, ...}: let
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
          background = "151515ff";
          text = "e8e8d3ff";
          match = "fad07aff";
          selection = "404040ff";
          selection-text = "e8e8d3ff";
          selection-match = "fad07aff";
          border = "8197bfff";
        };
        border.width = 1;
        border.radius = 10;
      };
    };
  };
in {
  den.aspects.fuzzel-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "fuzzel-config/${user.userName}@${host.name}";
        homeManager = fuzzelHomeManager;
      })
    ];
  };
}
