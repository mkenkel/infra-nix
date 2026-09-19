{den, ...}: {
  den.aspects.librewolf = {
    nixos = {pkgs, ...}: {
      programs.librewolf = {
        enable = true;
        globalExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
          privacy-badger
          uBlock-origin
          stylus
        ];
      };
    };
  };
}
