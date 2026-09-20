{den, ...}: {
  den.aspects.via = {
    includes = [
      (den.batteries.unfree [
        "via"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        via
      ];
    };
  };
}
