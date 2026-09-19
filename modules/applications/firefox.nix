{den, ...}: let
  firefoxHomeManager = {config, ...}: {
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };
in {
  den.aspects.firefox = {
    homeManager = firefoxHomeManager;
  };
}
