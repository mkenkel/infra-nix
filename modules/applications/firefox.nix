{den, ...}: let
  firefoxHomeManager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.firefox = {
      enable = true;
      # nixpkgs has no aarch64-darwin binary cache entry for Firefox, so a
      # real `package` there means compiling it from source (hours). On
      # Darwin, home-manager only manages the profile/policies; the actual
      # app comes from the Homebrew cask (see hostnames/mktogo.nix), which
      # already lands at the default "Library/Application Support/Firefox"
      # configPath the module uses on Darwin — so no override there.
      package = lib.mkIf pkgs.stdenv.isDarwin null;
      configPath = lib.mkIf (!pkgs.stdenv.isDarwin) "${config.xdg.configHome}/mozilla/firefox";
    };

    # nixpkgs' firefox package is normally run through a wrapper script that
    # sets MOZ_LEGACY_PROFILES=1, which makes Firefox/LibreWolf trust
    # profiles.ini's Default=1 entry directly. Without that wrapper (as on
    # Darwin, where we use the raw Homebrew app), Firefox's newer per-install
    # profile isolation kicks in instead: on every launch where it doesn't
    # recognize this specific app-bundle path in installs.ini, it mints a
    # brand-new empty profile rather than adopting the home-manager-managed
    # "default" one — the "profile cannot be loaded" error. Setting this env
    # var for the whole login session (so it applies no matter how the .app
    # is launched — Dock, Spotlight, etc.) reproduces the wrapper's behavior.
    # Also covers librewolf.nix, which shares this failure mode.
    launchd.agents.moz-legacy-profiles = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = ["/bin/launchctl" "setenv" "MOZ_LEGACY_PROFILES" "1"];
        RunAtLoad = true;
      };
    };
  };
in {
  den.aspects.firefox = {
    homeManager = firefoxHomeManager;
  };
}
