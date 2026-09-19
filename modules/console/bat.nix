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
  den.aspects.bat-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "bat-config/${user.userName}@${host.name}";
        homeManager = batHomeManager;
      })
    ];
  };
}
