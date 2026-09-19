{den, ...}: let
  neovimHomeManager = {pkgs, ...}: {
    programs.neovim = {
      enable = false;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      extraLuaPackages = ps: [
        ps.magick
      ];
      extraPackages = [
        pkgs.imagemagick
      ];
    };
  };
in {
  den.aspects.neovim = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "neovim/${user.userName}@${host.name}";
        homeManager = neovimHomeManager;
      })
    ];
  };
}
