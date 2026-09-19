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
  den.aspects.neovim-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "neovim-config/${user.userName}@${host.name}";
        homeManager = neovimHomeManager;
      })
    ];
  };
}
