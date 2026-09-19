{den, ...}: let
  gpgAgentHomeManager = {pkgs, ...}: {
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 60;
      maxCacheTtl = 120;
      pinentry = {
        package = pkgs.pinentry-curses;
      };
      extraConfig = ''
        ttyname $GPG_TTY
      '';
    };
  };
in {
  den.aspects.gpg-agent = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "gpg-agent/${user.userName}@${host.name}";
        homeManager = gpgAgentHomeManager;
      })
    ];
  };
}
