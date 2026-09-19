{den, ...}: {
  den.aspects.matt = {
    # (9)
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "fish")
      den.aspects.fish-config
      den.aspects.tmux-config
      den.aspects.bat-config
      den.aspects.fuzzel-config
      den.aspects.git-config
      den.aspects.gpg-config
      den.aspects.neovim-config
      den.aspects.starship-config
      den.aspects.fzf-config
      den.aspects.gpg-agent-config
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
