{den, ...}: let
  programmingHomeManager = {pkgs, ...}: {
    home.packages = [
      pkgs.ansible
      pkgs.ansible-lint
      pkgs.ansible-navigator
      pkgs.arduino-ide
      pkgs.docker-compose-language-service
      pkgs.cue
      pkgs.gcc
      pkgs.gh
      pkgs.gitflow
      pkgs.gnumake
      pkgs.lazygit
      pkgs.lua-language-server
      pkgs.kubectl
      pkgs.nim
      pkgs.nimble
      pkgs.nil
      pkgs.nimlsp
      pkgs.nodejs
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
