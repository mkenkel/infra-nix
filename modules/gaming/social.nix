{den, ...}: {
  den.aspects.social = {
    includes = [
      (den.batteries.unfree [
        "discord"
        "discordo"
        "discord-sh"
        "vesktop"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        discord
        discordo
        discord-sh
        vesktop
      ];
    };
  };
}
