{den, ...}: let
  programmingHomeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [
        ansible
        ansible-lint
        ansible-navigator
        arduino-ide
        docker-compose-language-service
        cue
        gcc
        gh
        gitflow
        gnumake
        jq
        lazygit
        lua-language-server
        kubectl
        nim
        nimble
        nil
        nimlsp
        nodejs
        (pkgs.python313.withPackages (
          ps:
            with ps; [
              asyncssh
              fastapi
              uvicorn
              aiomqtt
              sounddevice
              soundfile
              pyyaml
              beautifulsoup4
              packaging
              pandas
              selenium
              paramiko
              pip
              pylint
              regex
              requests
              setuptools
              tkinter
            ]
        ))
        pkgs.pyright
        pkgs.rustup
        pkgs.vim
        pkgs.yaml-language-server
        pkgs.zsh-autosuggestions
      ];
  };
in {
  den.aspects.programming = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "programming/${user.userName}@${host.name}";
        homeManager = programmingHomeManager;
      })
    ];
  };
}
