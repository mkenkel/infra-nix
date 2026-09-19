{den, ...}: {
  den.aspects.fish-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "fish-config/${user.userName}@${host.name}";

        homeManager.programs.fish = {
          enable = true;
          shellAliases.ll = "ls -la";
          shellAbbrs.gco = "git checkout";
        };
      })
    ];
  };
}
