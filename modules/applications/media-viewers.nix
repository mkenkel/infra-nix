{
  den.aspects.media-viewers.homeManager = {pkgs, ...}: let
    imageTypes = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/avif"
      "image/bmp"
      "image/tiff"
      "image/svg+xml"
      "image/heif"
      "image/heic"
    ];
    videoTypes = [
      "video/quicktime"
      "video/mp4"
      "video/x-m4v"
      "video/x-matroska"
      "video/webm"
      "video/mpeg"
      "video/x-msvideo"
    ];
    assign = app: types:
      builtins.listToAttrs (map (t: {
          name = t;
          value = app;
        })
        types);
  in {
    programs.mpv = {
      enable = true;
      config = {
        # VA-API decode on the AMD GPU; gpu-next tone-maps the iPhone's HDR clips.
        hwdec = "auto-safe";
        vo = "gpu-next";
        # Keep it from ever outgrowing the floating window rule in mango.
        autofit-larger = "60%x60%";
      };
    };

    programs.imv = {
      enable = true;
      # imv 5.0.1's man page lists Ctrl+r for rotate but the source never
      # binds it (only `r` = reset), so every rotate/flip key is defined here.
      # `f` is taken (fullscreen), hence Shift+H/V for flips.
      settings.binds = {
        "<Ctrl+r>" = "rotate by 90"; # clockwise
        "<Shift+R>" = "rotate by 270"; # counterclockwise
        "<Shift+H>" = "flip horizontal";
        "<Shift+V>" = "flip vertical";
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        assign "imv.desktop" imageTypes
        // assign "mpv.desktop" videoTypes;
    };
  };
}
