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
          #!/usr/bin/env bash
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

          fmt_resets_in() {
            local resets_at="$1"
            [ -z "$resets_at" ] && return
            local now secs_left h m
            now=$(date +%s)
            secs_left=$((resets_at - now))
            [ "$secs_left" -lt 0 ] && secs_left=0
            h=$((secs_left / 3600))
            m=$(((secs_left % 3600) / 60))
            printf '%dh%dm' "$h" "$m"
          }

          FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
          FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
          WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
          WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

          LIMITS=""
          if [ -n "$FIVE_H_PCT" ]; then
            LIMITS="5h: $(printf '%.0f' "$FIVE_H_PCT")% (resets $(fmt_resets_in "$FIVE_H_RESET"))"
          fi
          if [ -n "$WEEK_PCT" ]; then
            WEEK_STR="7d: $(printf '%.0f' "$WEEK_PCT")% (resets $(fmt_resets_in "$WEEK_RESET"))"
            LIMITS="''${LIMITS:+$LIMITS | }$WEEK_STR"
          fi

          echo "[$MODEL] $BAR $PCT% | $COST_FMT | ''${MINS}m ''${SECS}s''${LIMITS:+ | $LIMITS}"
        '';
      };
    };
  };
}
