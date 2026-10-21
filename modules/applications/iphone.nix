{
  den.aspects.iphone.nixos = {pkgs, ...}: {
    # usbmuxd multiplexes the USB connection to iOS devices.
    services.usbmuxd.enable = true;

    # Lets gvfs-aware file managers browse the phone.
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      libimobiledevice # idevicepair, ideviceinfo, ...
      ifuse # mount the camera roll: ifuse ~/iphone
    ];
  };
}
