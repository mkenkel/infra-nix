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
  };
in {
  den.aspects.firefox = {
    homeManager = firefoxHomeManager;
  };
}
