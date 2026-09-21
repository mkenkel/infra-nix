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
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
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

      # settings.json also holds interactive, non-declarative state
      # (effortLevel, theme, ...) that Claude Code itself rewrites, so this
      # jq-merges the statusLine/hooks keys in rather than overwriting the
      # whole file the way home.file would - anything else in there survives
      # both this activation and Claude Code's own edits.
      home.activation.claudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
        settingsFile="$HOME/.claude/settings.json"
        desired=${lib.escapeShellArg (builtins.toJSON {
          statusLine = {
            type = "command";
            command = "~/.claude/scripts/statusline-command.sh";
            padding = 2;
          };
          hooks = {
            PreToolUse = [
              {
                hooks = [
                  {
                    type = "command";
                    command = "~/.claude/scripts/pre-tool-use-activity.sh";
                  }
                ];
              }
            ];
            Stop = [
              {
                hooks = [
                  {
                    type = "command";
                    command = "~/.claude/scripts/stop-activity.sh";
                  }
                ];
              }
            ];
          };
        })}
        if [ -n "''${DRY_RUN_CMD:-}" ]; then
          echo "Would merge statusLine/hooks into $settingsFile"
        else
          mkdir -p "$(dirname "$settingsFile")"
          if [ -f "$settingsFile" ]; then
            ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$settingsFile" <(printf '%s' "$desired") \
              > "$settingsFile.tmp"
            mv "$settingsFile.tmp" "$settingsFile"
          else
            printf '%s' "$desired" > "$settingsFile"
          fi
        fi
      '';
    };
  };
}
