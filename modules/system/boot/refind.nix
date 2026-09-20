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
    config,
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
      maxGenerations = 10;
      extraConfig = "include themes/regular-dark/theme.conf\n";
      additionalFiles =
        (flattenDir lib "themes/regular-dark/icons/${refindThemeResolution}" iconsDir)
        // {
          "themes/regular-dark/theme.conf" = themeConf;
          "themes/regular-dark/fonts/source-code-pro-extralight-14.png" = themeSrc + "/fonts/source-code-pro-extralight-14.png";
        };
    };

    # This board's firmware ignores the NVRAM boot order and always launches
    # \EFI\BOOT\BOOTX64.EFI regardless of which entry is selected/first, so
    # mirror rEFInd's whole directory there too (config/kernels/theme, not
    # just the binary) after every switch and on every boot. installBootLoader
    # (which regenerates /EFI/refind) always runs before systemd units are
    # (re)started during switch-to-configuration, so this unit always mirrors
    # the fresh files, never a stale copy.
    systemd.services.refind-fallback-mirror = {
      description = "Mirror rEFInd into EFI/BOOT for firmware that ignores NVRAM boot order";
      after = ["local-fs.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";
      script = ''
        esp="${config.boot.loader.efi.efiSysMountPoint}"
        rm -rf "$esp/EFI/BOOT"
        mkdir -p "$esp/EFI/BOOT"
        cp -a "$esp/EFI/refind/." "$esp/EFI/BOOT/"
      '';
    };
  };
}
