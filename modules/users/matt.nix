{den, ...}: {
  den.aspects.matt = {
    # (9)
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "fish")
      den.aspects.fish
      den.aspects.tmux
      den.aspects.bat
      den.aspects.fuzzel
      den.aspects.git
      den.aspects.gpg
      den.aspects.neovim
      den.aspects.starship
      den.aspects.fzf
      den.aspects.gpg-agent
    ]; # (10)
    nixos = {pkgs, ...}: {
      users.users.matt.packages = with pkgs; [
        vim
      ];
    };
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
