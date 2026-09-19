{den, ...}: let
  batHomeManager = {pkgs, ...}: {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
    };
  };
in {
  den.aspects.bat = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "bat/${user.userName}@${host.name}";
        homeManager = batHomeManager;
      })
    ];
  };
}
