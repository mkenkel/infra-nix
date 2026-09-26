{den, ...}: {
  # NixOS-WSL. `wsl.enable` / `wsl.defaultUser` come from den's wsl battery
  # (host.wsl.enable in hosts.nix) + den.batteries.primary-user.
  den.aspects.updog = {
    includes = [
      den.batteries.hostname
      den.aspects.virt-podman
      den.aspects.locale-us-eastern
      den.aspects.nix-settings
    ];
    nixos = {pkgs, ...}: {
      system.stateVersion = "26.05";

      # Same uid the previous (nixified) WSL config gave matt, so an
      # existing /home/matt stays owned by the right account.
      users.users.matt.uid = 1001;

      # WSL shells aren't logind sessions, so without linger user@1001 is
      # stopped ~10s after boot's short-lived login session ends - taking
      # tmux (whose panes run as scopes under it) and the fish-autostarted
      # terminal down with it on the first launch.
      users.users.matt.linger = true;

      # Appending the Windows PATH (~40 /mnt/c dirs, served over 9P) makes
      # every interactive fish start ~2.1s instead of ~80ms, which every new
      # tmux window/pane pays. Windows tools stay reachable by full path.
      wsl.interop.includePath = false;

      environment.systemPackages = with pkgs; [
        age
        alejandra
        bash-snippets
        cilium-cli
        curl
        envsubst
        fluxcd
        git
        glibc
        glibc_multi
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
        # packer
        paperkey
        podman
        podman-compose
        sshpass
        taplo
        # terraform
        terraform-ls
        tftp-hpa
        timoni
        unzip
        vim
        wget
        yazi
      ];
    };
  };
}
