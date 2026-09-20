{...}: {
  den.aspects.boot-grub.nixos = {
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
    };
  };
}
