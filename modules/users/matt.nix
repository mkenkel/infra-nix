{den, ...}: {
  den.aspects.matt = {
    # (9)
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ]; # (10)
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
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
        fish
        #freecad
        fzf
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
        # obsidian
        playerctl
        prismlauncher
        qalculate-qt
        qmk
        ripgrep
        slurp
        showmethekey
        sops
        # spotify
        starship
        tree
        # via
        virt-manager
        virt-viewer
        wev
        wf-recorder
        wlr-randr
        yamlfmt
        yamllint
      ];
    };
  };
}
