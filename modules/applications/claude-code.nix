{den, ...}: {
  den.aspects.claude = {
    includes = [
      (den.batteries.unfree [
        "claude-code"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        claude-code
      ];
    };
    darwin = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        claude-code
      ];
    };
    # Scripts live in ./_claude (import-tree skips `_` paths). `force` lets
    # home-manager take over the copies previously placed there by hand.
    homeManager = {...}: {
      home.file = builtins.listToAttrs (map (name: {
        name = ".claude/scripts/${name}";
        value = {
          source = ./_claude + "/${name}";
          executable = true;
          force = true;
        };
      }) [
        "statusline-command.sh"
        "pre-tool-use-activity.sh"
        "stop-activity.sh"
      ]);
    };
  };
}
