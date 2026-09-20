# Material 3 tonal roles, shared across every aspect that needs to look
# like part of the same desktop (mangobar's CSS, mango's own window-border/
# urgent colors, fuzzel). Plain data, `import`ed directly rather than
# placed under modules/ - that tree is auto-discovered by import-tree and
# every file there is expected to be a dendritic module, not a bare
# attrset, so this deliberately lives outside it.
#
# Bare RRGGBB: mangobar's CSS wants "#rrggbb", mango's own config and
# fuzzel both want "rrggbbaa", so each use site appends whatever it needs.
{
  surface = "171310";
  surfaceContainer = "221c16";
  surfaceContainerHigh = "2e261d";
  outline = "3a2f24";
  onSurface = "f5e6d3";
  onSurfaceVariant = "a8927c";

  primary = "f2994a";
  onPrimary = "1c1410";
  primaryContainer = "4a3420";
  onPrimaryContainer = "ffd9a8";

  secondary = "6a994e";
  onSecondary = "12190d";

  tertiary = "f4c95d";
  onTertiary = "241a03";

  error = "d9534f";
  onError = "2a0a08";
}
