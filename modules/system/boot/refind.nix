{inputs, ...}: let
  refindThemeResolution = "256-96";

  # rEFInd's `additionalFiles` copies files one at a time (no directory
  # copies), so flatten every file under `srcDir` into
  # "<destPrefix>/<filename>" = <source path> entries.
  flattenDir = lib: destPrefix: srcDir:
    lib.listToAttrs (map
      (name: lib.nameValuePair "${destPrefix}/${name}" (srcDir + "/${name}"))
      (builtins.attrNames (builtins.readDir srcDir)));
in {
  den.aspects.boot-refind.nixos = {
    pkgs,
    lib,
    ...
  }: let
    themeSrc = inputs.refind-theme-regular;
    iconsDir = themeSrc + "/icons/${refindThemeResolution}";

    # Same as upstream's theme.conf, but with the dark banner/selection art
    # enabled instead of the default light set, per the theme's README.
    themeConf = pkgs.writeText "theme.conf" ''
      icons_dir themes/regular-dark/icons/${refindThemeResolution}
      big_icon_size 256
      small_icon_size 96

      banner themes/regular-dark/icons/${refindThemeResolution}/bg_dark.png

      selection_big themes/regular-dark/icons/${refindThemeResolution}/selection_dark-big.png
      selection_small themes/regular-dark/icons/${refindThemeResolution}/selection_dark-small.png

      font themes/regular-dark/fonts/source-code-pro-extralight-14.png
    '';
  in {
    boot.loader.efi.canTouchEfiVariables = true;

    # rEFInd takes over as the default EFI boot entry, but doesn't remove
    # systemd-boot's own EFI binary/NVRAM entry, so it's still selectable
    # from the firmware boot menu (F11/F12) as a fallback.
    boot.loader.systemd-boot.enable = false;
    boot.loader.grub.enable = false;

    boot.loader.refind = {
      enable = true;
      extraConfig = "include themes/regular-dark/theme.conf\n";
      additionalFiles =
        (flattenDir lib "themes/regular-dark/icons/${refindThemeResolution}" iconsDir)
        // {
          "themes/regular-dark/theme.conf" = themeConf;
          "themes/regular-dark/fonts/source-code-pro-extralight-14.png" = themeSrc + "/fonts/source-code-pro-extralight-14.png";
        };
    };
  };
}
