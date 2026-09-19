{
  den.aspects.social.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      discord
      discordo
      discord-sh
      vesktop
    ];
  };
}
