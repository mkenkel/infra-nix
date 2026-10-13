{
  den,
  inputs,
  ...
}: let
  workmuxHomeManager = {pkgs, ...}: {
    home.packages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.workmux];

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
  flake-file.inputs.llm-agents.url = "github:numtide/llm-agents.nix";

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
