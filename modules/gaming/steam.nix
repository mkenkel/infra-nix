{den, ...}: {
  den.aspects.steam = {
    includes = [
      (den.batteries.unfree [
        "steam"
        "steam-unwrapped"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        protonup-ng
        lutris
        vulkan-tools
        mesa-demos
      ];

      programs = {
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          package = pkgs.steam.override {
            extraLibraries = pkgs: [pkgs.pkgsi686Linux.pipewire.jack];
            extraPkgs = pkgs: [pkgs.wineasio];
          };
        };
        gamemode.enable = true;
      };
    };
  };
}
