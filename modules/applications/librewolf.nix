{den, ...}: let
  librewolfHomeManager = {config, ...}: {
    programs.librewolf = {
      enable = true;
      globalExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
        privacy-badger
        {
          package = ublock-origin;
          settings = {
            private_browsing = true;
          };
        }
      ];
    };
  };
in {
  den.aspects.librewolf = {
    homeManager = librewolfHomeManager;
  };
}
