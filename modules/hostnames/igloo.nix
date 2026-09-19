{den, ...}: {
  den.aspects.igloo = {
    # (6)
    includes = [
      den.batteries.hostname
      den.aspects.boot-systemd
      den.aspects.virt-docker
      den.aspects.virt-podman
      den.aspects.locale-us-eastern
      den.aspects.network-manager
      den.aspects.openssh
      den.aspects.nix-settings
      den.aspects.polkit
      den.aspects.realtime-audio
      den.aspects.graphics
      den.aspects.steam
      den.aspects.social
    ]; # (7)
    nixos = {pkgs, ...}: {
      imports = [./_nixos/hardware-configuration.nix];
      system.stateVersion = "26.05";
      environment.systemPackages = with pkgs; [
        age
        bashSnippets
        bottles
        cilium-cli
        curl
        envsubst
        fluxcd
        git
        glibc
        glibc_multi
        # google-chrome
        go
        gopls
        helm-ls
        hubble
        json2yaml
        kompose
        kube-linter
        kubectl
        kustomize
        lua-language-server
        lua5_1
        luajit
        luaPackages.tree-sitter-cli
        nfs-utils
        nixfmt
        openssl
        pa-notify
        # packer
        paperkey
        pavucontrol # Lets you disable inputs/outputs, can help if game auto-connects to bad IOs
        podman
        podman-compose
        pw-volume
        pwvucontrol
        qemu
        qpwgraph # Lets you view pipewire graph and connect IOs
        rtaudio
        # slack
        sshpass
        taplo
        # terraform
        terraform-ls
        tftp-hpa
        timoni
        unzip
        unzip # Used by patch-nixos.sh
        vial
        vim
        virtiofsd
        vlc
        # vscode
        vscodium
        wget
        # wineWowPackages.stable
        # wineWowPackages.waylandFull
        winetricks
        wl-clipboard
      ];
    };
  };
}
