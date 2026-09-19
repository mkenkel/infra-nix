{den, ...}: let
  fzfHomeManager = {
    programs.fzf = {
      enable = true;
    };
  };
in {
  den.aspects.fzf-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "fzf-config/${user.userName}@${host.name}";
        homeManager = fzfHomeManager;
      })
    ];
  };
}
