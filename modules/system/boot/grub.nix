{inputs, ...}: let
  # See lib/monitors.nix - grub2-theme's customResolution wants a literal
  # "WIDTHxHEIGHT" and overrides its own "screen" enum when set, so this
  # skips the lossy 1080p/2k/4k/ultrawide category guess entirely and just
  # uses the exact monitor's real pixels. Grub itself only ever addresses
  # one screen (no per-output config), so this reads the first monitor.
  monitor = builtins.head (import ../../../lib/monitors.nix);
in {
  den.aspects.boot-grub.nixos = {
    imports = [inputs.grub2-themes.nixosModules.default];

    # efiInstallAsRemovable below writes directly to the fallback path instead
    # of an NVRAM entry, so this must stay off (NixOS asserts on the combo).
    boot.loader.efi.canTouchEfiVariables = false;

    boot.loader.systemd-boot.enable = false;
    boot.loader.refind.enable = false;

    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      # This board's firmware ignores the NVRAM boot order and always boots
      # \EFI\BOOT\BOOTX64.EFI, so install there directly instead of relying
      # on an efibootmgr entry the firmware won't honor anyway.
      efiInstallAsRemovable = true;
      useOSProber = true;
      configurationLimit = 10;
      memtest86.enable = true;
    };

    boot.loader.grub2-theme = {
      enable = true;
      theme = "vimix";
      icon = "color";
      customResolution = "${toString monitor.width}x${toString monitor.height}";
    };
  };
}
