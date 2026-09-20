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
      den.aspects.firefox
      den.aspects.librewolf
      den.aspects.fonts
      den.aspects.kitty
      den.aspects.git
      den.aspects.gpg
      den.aspects.neovim
      den.aspects.starship
      den.aspects.fzf
      den.aspects.gpg-agent
      den.aspects.programming
      den.aspects.spotify
      den.aspects.obsidian
      # Wayland/Linux desktop-only aspects — skipped on Darwin hosts, where
      # these home-manager options don't exist / assert on platform.
      (
        {host, ...}:
          if host.class == "darwin"
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
            alacritty
            alacritty-theme
            #bambu-studio
            brightnessctl
            btop
            chafa
            cmatrix
            fastfetch
            feh
            ffmpeg
            #freecad
            gimp
            giph
            grc
            grim
            haskellPackages.sixel
            htop
            inkscape
            kitty-themes
            libsixel
            libvirt
            lsd
            lsof
            neovim
            nwg-look
            # playerctl is currently broken in nixpkgs (pkgs.playerctl.meta.broken)
            prismlauncher
            qalculate-qt
            qmk
            ripgrep
            slurp
            showmethekey
            sops
            tree
            virt-manager
            virt-viewer
            wev
            wf-recorder
            wlr-randr
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
