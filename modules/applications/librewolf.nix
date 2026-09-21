{
  den,
  inputs,
  ...
}: let
  librewolfHomeManager = {
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.nur.modules.homeManager.default];
    programs.librewolf = {
      enable = true;
      # Same reasoning as firefox.nix: no aarch64-darwin binary cache entry,
      # so let Homebrew's cask (hostnames/mktogo.nix) supply the app and
      # only manage the profile/policies here. The module's own Darwin
      # configPath default ("Library/Application Support/LibreWolf")
      # already matches where that cask lands, so no override needed.
      package = lib.mkIf pkgs.stdenv.isDarwin null;
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

    # nixpkgs' firefox/librewolf packages are normally run through a wrapper
    # script that sets MOZ_LEGACY_PROFILES=1, which makes them trust
    # profiles.ini's Default=1 entry directly. Without that wrapper (as on
    # Darwin, where we use the raw Homebrew app), Firefox's newer per-install
    # profile isolation kicks in instead: on every launch where it doesn't
    # recognize this specific app-bundle path in installs.ini, it mints a
    # brand-new empty profile rather than adopting the home-manager-managed
    # "default" one — the "profile cannot be loaded" error. Setting this env
    # var for the whole login session (so it applies no matter how the .app
    # is launched — Dock, Spotlight, etc.) reproduces the wrapper's behavior.
    launchd.agents.moz-legacy-profiles = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = ["/bin/launchctl" "setenv" "MOZ_LEGACY_PROFILES" "1"];
        RunAtLoad = true;
      };
    };
  };
in {
  den.aspects.librewolf = {
    includes = [(den.batteries.unfree ["imagus" "keeper-password-manager"])];
    homeManager = librewolfHomeManager;
  };
}
