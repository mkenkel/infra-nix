{den, ...}: let
  fzfHomeManager = {
    programs.fzf = {
      enable = true;
    };
  };
in {
  den.aspects.fzf = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "fzf/${user.userName}@${host.name}";
        homeManager = fzfHomeManager;
      })
    ];
  };
}
