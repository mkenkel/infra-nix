{den, ...}: let
  fontsHomeManager = {pkgs, ...}: {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      # Plain text font referenced by mako/swaylock. gtk pulls in its own
      # display font (Monaspace) via its own font.package option, since
      # nothing else references it.
      jetbrains-mono

      # Named by both kitty (font.name) and mangobar's CSS (mango.nix);
      # declared once here instead of relying on kitty's font.package to
      # install it as a side effect for mangobar too.
      maple-mono.NF

      # Full Nerd Fonts glyph set (Font Awesome, Material Design Icons,
      # Devicons, Codicons, ...) with no monospace text glyphs of its own.
      # Used as a fallback font-family so any icon glyph renders correctly
      # regardless of whether the primary display font's own Nerd Font
      # patch happens to include it.
      nerd-fonts.symbols-only
    ];
  };
in {
  den.aspects.fonts = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "fonts/${user.userName}@${host.name}";
        homeManager = fontsHomeManager;
      })
    ];
  };
}
