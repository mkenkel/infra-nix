{
  den.aspects.iphone.homeManager = {
    config,
    pkgs,
    ...
  }: {
    # Sidebar shortcuts in Thunar (and any other GTK file chooser).
    gtk.gtk3.bookmarks = [
      "file://${config.home.homeDirectory}/iphone iPhone"
      "file://${config.home.homeDirectory}/Videos/iphone iPhone Imports"
      "file://${config.home.homeDirectory}/Videos/resolve Resolve Media"
    ];

    # Default new folders to list (details) view.
    xfconf.settings.thunar = {
      "default-view" = "ThunarDetailsView";
      "last-view" = "ThunarDetailsView";
    };

    # Right-click video files -> "Convert for Resolve" (see resolve-convert in
    # fish.nix). Opens a kitty window so progress is visible. Output goes to a
    # fixed dir because the phone's mount is read-only.
    xdg.configFile."Thunar/uca.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>video-x-generic</icon>
          <name>Convert for Resolve</name>
          <unique-id>1700000000000001</unique-id>
          <command>${pkgs.kitty}/bin/kitty fish -c 'resolve-convert -o $HOME/Videos/resolve $argv; read -P "Done - press Enter to close"' -- %F</command>
          <description>Convert to ProRes for DaVinci Resolve into ~/Videos/resolve</description>
          <patterns>*</patterns>
          <video-files/>
        </action>
      </actions>
    '';
  };

  den.aspects.iphone.nixos = {pkgs, ...}: let
    # Runs when an iPhone is plugged in: wait for the Trust prompt to be
    # accepted, mount the camera roll, open it in Thunar, then clean up on
    # unplug. For bulk copying + conversion use `iphone-import` (see fish.nix).
    #
    # Sounds: freedesktop sound theme by default. Point these at any file
    # pw-play can read (wav/ogg/flac/...) to use your own.
    sounds = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo";
    connectSound = "${sounds}/device-added.oga";
    disconnectSound = "${sounds}/device-removed.oga";

    iphoneConnect = pkgs.writeShellScript "iphone-connect" ''
      export PATH=/run/wrappers/bin:${pkgs.lib.makeBinPath [pkgs.coreutils pkgs.gnugrep pkgs.libimobiledevice pkgs.ifuse pkgs.libnotify pkgs.pipewire pkgs.thunar]}:$PATH
      # NixOS gives user services a minimal default PATH (coreutils, findutils,
      # ...), not the login PATH. Thunar and every app it launches (imv, mpv,
      # ...) inherit this, and GIO hides apps whose binary isn't on PATH, so
      # add the user's profile dirs explicitly.
      export PATH="$PATH:/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:/nix/profile/bin:$HOME/.local/state/nix/profile/bin:/run/current-system/sw/bin"
      mnt="$HOME/iphone"
      mkdir -p "$mnt"

      # Asking to pair is what makes the phone show "Trust This Computer?".
      # Give it a minute to be unlocked and accepted.
      paired=false
      for _ in $(seq 30); do
        if idevicepair validate >/dev/null 2>&1; then paired=true; break; fi
        idevicepair pair >/dev/null 2>&1 || true
        sleep 2
      done
      if [ "$paired" != true ]; then
        notify-send "iPhone" "Not trusted - unlock the phone and tap Trust, then replug."
        exit 1
      fi

      mountpoint -q "$mnt" || ifuse "$mnt" || {
        notify-send "iPhone" "Mount failed"
        exit 1
      }
      notify-send "iPhone" "Camera roll mounted at ~/iphone"
      pw-play ${connectSound} >/dev/null 2>&1 &
      thunar "$mnt/DCIM" &

      # Stay alive until the phone is unplugged, then unmount.
      while idevice_id -l 2>/dev/null | grep -q .; do sleep 3; done
      fusermount -u -z "$mnt" || true
      # Foreground on purpose: the service's cgroup is torn down on exit.
      pw-play ${disconnectSound} >/dev/null 2>&1 || true
    '';
  in {
    # usbmuxd multiplexes the USB connection to iOS devices.
    services.usbmuxd.enable = true;

    # Lets gvfs-aware file managers browse the phone.
    services.gvfs.enable = true;

    # GUI file manager for browsing/selecting clips.
    programs.thunar.enable = true;

    # Thunar only shows thumbnails when tumbler is running; the thumbnailer
    # packages below teach it HEIC (libheif) and video (ffmpegthumbnailer).
    services.tumbler.enable = true;
    environment.pathsToLink = ["/share/thumbnailers"];

    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      libheif
      # nixpkgs ships heif-thumbnailer but not the .thumbnailer descriptor.
      (writeTextDir "share/thumbnailers/heif.thumbnailer" ''
        [Thumbnailer Entry]
        TryExec=${libheif.bin}/bin/heif-thumbnailer
        Exec=${libheif.bin}/bin/heif-thumbnailer -s %s %i %o
        MimeType=image/heif;image/heic;image/heif-sequence;image/heic-sequence;
      '')
      libimobiledevice # idevicepair, ideviceinfo, ...
      ifuse # mount the camera roll: ifuse ~/iphone
    ];

    # Apple vendor id 05ac, iPhone/iPad product ids 0x129x/0x12ax.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="05ac", ATTR{idProduct}=="12[9a][0-9a-f]", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}="iphone-connect.service"
    '';

    systemd.user.services.iphone-connect = {
      description = "Mount and open a connected iPhone";
      serviceConfig = {
        Type = "simple";
        ExecStart = iphoneConnect;
      };
    };
  };
}
