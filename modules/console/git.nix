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
  den.aspects.git = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "git/${user.userName}@${host.name}";
        homeManager = gitHomeManager;
      })
      # On WSL, hand credentials off to Git for Windows' credential manager
      # so both sides share one login.
      ({host, ...}:
        if host.wsl.enable or false
        then {
          homeManager.programs.git.settings.credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
        }
        else {})
    ];
  };
}
