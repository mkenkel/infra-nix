{
  den,
  inputs,
  ...
}: let
  librewolfHomeManager = {pkgs, ...}: {
    imports = [inputs.nur.modules.homeManager.default];
    programs.librewolf = {
      enable = true;
      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "layout.css.prefers-color-scheme.content-override" = 0;
        "ui.systemUsesDarkTheme" = 1;
        "general.autoScroll" = true;
      };
      profiles.default.search = {
        force = true;
        default = "google-web-search";
        engines."google-web-search" = {
          name = "Google Web Search";
          urls = [
            {
              template = "https://www.google.com/search?q={searchTerms}&udm=14";
            }
          ];
          definedAliases = ["@g"];
        };
      };
      profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        privacy-badger
        ublock-origin
        auto-tab-discard
        dearrow
        facebook-container
        imagus
        keeper-password-manager
        reddit-enhancement-suite
        return-youtube-dislikes
        sponsorblock
        to-google-translate
        youtube-shorts-block
      ];
      policies.ExtensionSettings."uBlock0@raymondhill.net".private_browsing = true;

      # LibreWolf wipes cookies/site data on shutdown by default
      # (privacy.sanitize.sanitizeOnShutdown); these are exempted so
      # logins persist across restarts.
      policies.Cookies.Allow = [
        "https://accounts.google.com"
        "https://google.com"
        "https://github.com"
        "https://www.github.com"
        "https://mail.google.com"
        "https://mail.uc.edu"
        "https://myaccount.google.com"
        "https://reddit.com"
        "https://uc.edu"
        "https://www.reddit.com"
        "https://www.uc.edu"
        "https://www.youtube.com"
        "https://youtube.com"
      ];
    };
  };
in {
  den.aspects.librewolf = {
    includes = [(den.batteries.unfree ["imagus" "keeper-password-manager"])];
    homeManager = librewolfHomeManager;
  };
}
