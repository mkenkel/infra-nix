{
  den,
  inputs,
  ...
}: {
  den.aspects.matt = {
    # (9)
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "fish")
      den.aspects.fish
      den.aspects.tmux
      den.aspects.bat
      den.aspects.claude
      den.aspects.git
      den.aspects.gpg
      den.aspects.neovim
      den.aspects.starship
      den.aspects.fzf
      den.aspects.gpg-agent
      den.aspects.programming
      # GUI apps/packages: skipped on WSL hosts, which are used headless
      # from a Windows-side terminal.
      (
        {host, ...}:
          if host.wsl.enable or false
          then {}
          else {
            includes = [
              den.aspects.librewolf
              den.aspects.fonts
              den.aspects.kitty
              den.aspects.spotify
              den.aspects.obsidian
            ];
            homeManager = {
              pkgs,
              lib,
              ...
            }: {
              home.packages = with pkgs;
                builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [
                  alacritty
                  alacritty-theme
                  #bambu-studio
                  brightnessctl
                  feh
                  #freecad
                  gimp
                  giph
                  grim
                  inkscape
                  kitty-themes
                  libvirt
                  nwg-look
                  prismlauncher
                  qalculate-qt
                  slurp
                  showmethekey
                  virt-manager
                  virt-viewer
                  wev
                  wf-recorder
                  wlr-randr
                ];
            };
          }
      )
      # Skipped on Darwin hosts: mango/river/fuzzel/gtk/via are Wayland-only
      # (options don't exist / assert on platform under home-manager).
      # Also skipped on WSL, which has no desktop session of its own.
      (
        {host, ...}:
          if host.class == "darwin" || (host.wsl.enable or false)
          then {}
          else {
            includes = [
              den.aspects.mango
              den.aspects.river
              den.aspects.fuzzel
              den.aspects.gtk
              den.aspects.via
            ];
          }
      )
    ]; # (10)
    nixos = {pkgs, ...}: {
      users.users.matt.packages = with pkgs; [
        vim
      ];
    };
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages =
        (with pkgs;
          builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [
            btop
            chafa
            cmatrix
            fastfetch
            ffmpeg
            grc
            haskellPackages.sixel
            htop
            libsixel
            lsd
            lsof
            neovim
            # playerctl is currently broken in nixpkgs (pkgs.playerctl.meta.broken)
            qmk
            ripgrep
            sops
            tree
            yamlfmt
            yamllint
          ])
        # Home configs here are wired in as a NixOS module (den.hosts), so
        # they apply via `nixos-rebuild switch`, not `home-manager switch`.
        # Still handy to have the CLI around for `home-manager generations`
        # / `home-manager expire-generations` on the resulting profiles.
        ++ [inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default];
    };
  };
}
