{
  den,
  inputs,
  ...
}: let
  workmuxHomeManager = {pkgs, ...}: {
    home.packages = [inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default];

    # Claude status hooks (working/waiting/done) live in claude-code.nix
    # alongside the other settings.json hooks.
    xdg.configFile."workmux/config.yaml".text = ''
      merge_strategy: rebase
      agent: claude
      panes:
        - command: <agent>
          focus: true
        - split: horizontal
    '';
  };
in {
  flake-file.inputs.workmux.url = "github:raine/workmux";

  den.aspects.workmux = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "workmux/${user.userName}@${host.name}";
        homeManager = workmuxHomeManager;
      })
    ];
  };
}
