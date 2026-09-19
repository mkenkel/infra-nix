{ den, ... }:
{
  den.aspects.igloo = {
    # (6)
    includes = [ den.batteries.hostname ]; # (7)
    nixos = { pkgs, ... }: {
      imports = [ ./_nixos/configuration.nix ]; # (8)
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
