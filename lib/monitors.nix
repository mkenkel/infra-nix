# Physical monitor layout, shared across window managers/compositors.
# Plain data, `import`ed directly rather than placed under modules/ - see
# palette-m3.nix in this same directory for why (import-tree auto-discovers
# every file under modules/ as a dendritic module, so a bare list/attrset
# has to live outside that tree).
#
# Each compositor's own config format is different (mango wants a
# "name:^..$,width:..,height:..,refresh:..,scale:..,x:..,y:.." string,
# sway/river/hyprland each want their own shape), so this only holds the
# raw values - each aspect is responsible for formatting them into
# whatever its own config wants.
[
  {
    name = "DP-3";
    width = 3840;
    height = 2160;
    refresh = 143.962997;
    scale = 1.25;
    x = 0;
    y = 0;
  }
]
