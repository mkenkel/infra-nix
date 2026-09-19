{den, ...}: let
  gitHomeManager = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "mkenkel";
        user.email = "mattsnoopy2@gmail.com";
      };
    };
  };
in {
  den.aspects.git-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "git-config/${user.userName}@${host.name}";
        homeManager = gitHomeManager;
      })
    ];
  };
}
