{den, ...}: {
  den.aspects.spotify = {
    includes = [
      (den.batteries.unfree [
        "spotify"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        spotify
      ];
    };
  };
}
