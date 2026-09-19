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
    homeManager = {...}: {
      home.file.".claude/statusline.sh" = {
        executable = true;
        text = ''
          #!/bin/bash
          input=$(cat)

          MODEL=$(echo "$input" | jq -r '.model.display_name')
          COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
          DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
          PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

          COST_FMT=$(printf '$%.2f' "$COST")
          DURATION_SEC=$((DURATION_MS / 1000))
          MINS=$((DURATION_SEC / 60))
          SECS=$((DURATION_SEC % 60))

          BAR_WIDTH=10
          FILLED=$((PCT * BAR_WIDTH / 100))
          EMPTY=$((BAR_WIDTH - FILLED))
          BAR=""
          [ "$FILLED" -gt 0 ] && printf -v FILL "%''${FILLED}s" && BAR="''${FILL// /▓}"
          [ "$EMPTY" -gt 0 ] && printf -v PAD "%''${EMPTY}s" && BAR="''${BAR}''${PAD// /░}"

          echo "[$MODEL] $BAR $PCT% | $COST_FMT | ''${MINS}m ''${SECS}s"
        '';
      };
    };
  };
}
