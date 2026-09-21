#!/bin/bash
# Line 1: Model | tokens used/total | % used <fullused> | % remain <fullremain> | thinking: on/off | running/idle since HH:MM
# Line 2: current: <progressbar> % | weekly: <progressbar> % | extra: <progressbar> $used/$limit
# Line 3: resets <time> | resets <datetime> | resets <date>
#
# Dot coloring logic:
#   Filled dots reflect pace: blue=under pace, green=within 20% above pace,
#   yellow=20-50% above pace, red=50%+ above pace
#   Empty dots reflect absolute remaining: dim (green), orange, yellow, red

set -f  # disable globbing

input=$(cat)

if [ -z "$input" ]; then
    printf "Claude"
    exit 0
fi

# ANSI colors matching oh-my-posh theme
blue='\033[38;2;0;153;255m'
orange='\033[38;2;255;176;85m'
green='\033[38;2;0;160;0m'
cyan='\033[38;2;46;149;153m'
red='\033[38;2;255;85;85m'
yellow='\033[38;2;230;200;0m'
white='\033[38;2;220;220;220m'
dim='\033[2m'
reset='\033[0m'

# Format token counts (e.g., 50k / 200k)
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

# Format number with commas (e.g., 134,938)
format_commas() {
    printf "%'d" "$1"
}

# Build a colored progress bar with pace-aware dot coloring.
# Filled dots reflect pace vs usage; empty dots reflect absolute remaining.
#
# Usage: build_bar <pct> <width> [pace_pct]
#   pct      — actual usage percentage (0-100)
#   width    — total number of dots
#   pace_pct — expected usage percentage at this point in the window (optional)
#              If omitted, falls back to legacy absolute coloring for filled dots.
#
# Filled dot colors (pace-aware):
#   blue   — usage < pace  (under-pacing, healthy buffer)
#   green  — usage within 20% above pace  (on track)
#   yellow — usage 20-50% above pace      (outpacing)
#   red    — usage 50%+ above pace        (significantly outpacing)
#
# Empty dot colors (absolute remaining — same as before):
#   dim        — under 50% used
#   orange     — 50-69% used
#   yellow     — 70-89% used
#   red        — 90%+ used
build_bar() {
    local pct=$1
    local width=$2
    local pace_pct="${3:-}"

    [ "$pct" -lt 0 ] 2>/dev/null && pct=0
    [ "$pct" -gt 100 ] 2>/dev/null && pct=100

    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))

    # --- Filled dot color: pace-based (or legacy absolute if no pace given) ---
    local filled_color
    if [ -n "$pace_pct" ] && [ "$pace_pct" -ge 0 ] 2>/dev/null; then
        # How far above/below pace are we?
        # above_pace_pct = usage - pace  (positive = outpacing)
        local above_pace=$(( pct - pace_pct ))
        if [ "$above_pace" -lt 0 ]; then
            # Under pace — solid blue
            filled_color="$blue"
        elif [ "$above_pace" -le 20 ]; then
            # Within 20% above pace — solid green
            filled_color="$green"
        elif [ "$above_pace" -le 50 ]; then
            # 20-50% above pace — solid yellow
            filled_color="$yellow"
        else
            # 50%+ above pace — solid red
            filled_color="$red"
        fi
    else
        # Legacy: color based on absolute usage
        if [ "$pct" -ge 90 ]; then filled_color="$red"
        elif [ "$pct" -ge 70 ]; then filled_color="$yellow"
        elif [ "$pct" -ge 50 ]; then filled_color="$orange"
        else filled_color="$green"
        fi
    fi

    # --- Empty dot color: absolute remaining (warning scale) ---
    local empty_color
    if [ "$pct" -ge 90 ]; then empty_color="$red"
    elif [ "$pct" -ge 70 ]; then empty_color="$yellow"
    elif [ "$pct" -ge 50 ]; then empty_color="$orange"
    else empty_color="$dim"
    fi

    local filled_str="" empty_str=""
    for ((i=0; i<filled; i++)); do filled_str+="●"; done
    for ((i=0; i<empty; i++)); do empty_str+="○"; done

    printf "${filled_color}${filled_str}${empty_color}${empty_str}${reset}"
}

# ===== Extract data from JSON =====
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd_raw=$(echo "$input" | jq -r '.cwd // ""')

# Build "parent/cwd" display from the current working directory
# Replaces $HOME prefix with ~, then shows the last two path components
build_pwd_display() {
    local dir="$1"
    # Replace home dir with ~
    dir="${dir/#$HOME/\~}"
    # Split into components
    local parent base
    base="${dir##*/}"
    parent="${dir%/*}"
    # If parent is empty or the same as dir (root or single component), just show dir
    if [ -z "$parent" ] || [ "$parent" = "$dir" ]; then
        echo "$dir"
    else
        # parent could be "~" or empty-ish; show "parent/base"
        local parent_base="${parent##*/}"
        if [ -z "$parent_base" ]; then
            parent_base="$parent"
        fi
        echo "${parent_base}/${base}"
    fi
}
pwd_display=$(build_pwd_display "$cwd_raw")

# Context window
size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
[ "$size" -eq 0 ] 2>/dev/null && size=200000

# Token usage
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
current=$(( input_tokens + cache_create + cache_read ))

used_tokens=$(format_tokens $current)
total_tokens=$(format_tokens $size)

if [ "$size" -gt 0 ]; then
    pct_used=$(( current * 100 / size ))
else
    pct_used=0
fi
pct_remain=$(( 100 - pct_used ))

used_comma=$(format_commas $current)
remain_comma=$(format_commas $(( size - current )))

# Check thinking status
thinking_on=false
settings_path="$HOME/.claude/settings.json"
if [ -f "$settings_path" ]; then
    thinking_val=$(jq -r '.alwaysThinkingEnabled // false' "$settings_path" 2>/dev/null)
    [ "$thinking_val" = "true" ] && thinking_on=true
fi

# ===== Running / Idle detection =====
# State is written by Claude Code hooks (pre-tool-use-activity.sh / stop-activity.sh).
# PreToolUse hook writes {"status":"running","idle_since":0,"project_dir":"..."}
# Stop hook writes {"status":"idle","idle_since":<epoch>,"project_dir":"..."}
# If the state file doesn't exist yet (first launch), treat as idle from now.
#
# Agent-team awareness: a session is only considered idle when no other session
# sharing the same project_dir is still running. This covers agent teams where
# multiple Claude instances collaborate on the same project.
session_id=$(echo "$input" | jq -r '.session_id // "default"' | tr -cd '[:alnum:]-_')
activity_state_file="/tmp/claude/activity-state-${session_id}.json"
mkdir -p /tmp/claude

now_epoch=$(date +%s)

activity_status="idle"
idle_since_epoch=0
this_project_dir=""

if [ -f "$activity_state_file" ]; then
    activity_status=$(jq -r '.status // "idle"' "$activity_state_file" 2>/dev/null)
    idle_since_epoch=$(jq -r '.idle_since // 0' "$activity_state_file" 2>/dev/null)
    this_project_dir=$(jq -r '.project_dir // ""' "$activity_state_file" 2>/dev/null)
fi

# If this session's own state file is missing, fall back to the cwd from input
if [ -z "$this_project_dir" ]; then
    this_project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
fi

# Check whether any peer session (same project_dir) is still running.
# A session is a peer if its state file records the same non-empty project_dir.
# Ignore stale state files (not modified in over 5 minutes) — these are likely
# from dead/crashed agents whose stop hook never fired.
stale_threshold=300  # seconds
team_running=false
if [ -n "$this_project_dir" ]; then
    for peer_file in /tmp/claude/activity-state-*.json; do
        [ "$peer_file" = "$activity_state_file" ] && continue
        [ -f "$peer_file" ] || continue
        # Skip stale files
        peer_mtime=$(stat -c %Y "$peer_file" 2>/dev/null || stat -f %m "$peer_file" 2>/dev/null)
        if [ -n "$peer_mtime" ]; then
            peer_age=$(( now_epoch - peer_mtime ))
            [ "$peer_age" -gt "$stale_threshold" ] && continue
        fi
        peer_project=$(jq -r '.project_dir // ""' "$peer_file" 2>/dev/null)
        [ "$peer_project" != "$this_project_dir" ] && continue
        peer_status=$(jq -r '.status // "idle"' "$peer_file" 2>/dev/null)
        if [ "$peer_status" = "running" ]; then
            team_running=true
            break
        fi
    done
fi

# Determine display: running vs idle
# Running if this session is running OR a team peer is running.
is_running=false
if [ "$activity_status" = "running" ] || $team_running; then
    is_running=true
fi

if $is_running; then
    running_status="${green}running${reset}"
else
    if [ "$idle_since_epoch" -gt 0 ]; then
        idle_time=$(date -d "@${idle_since_epoch}" +"%H:%M:%S" 2>/dev/null || date -r "${idle_since_epoch}" +"%H:%M:%S" 2>/dev/null)
        running_status="${dim}${idle_time}${reset}"
    else
        running_status="${dim}idle${reset}"
    fi
fi

# ===== LINE 1: pwd | Model | tokens | % used | % remain | thinking =====
line1=""
line1+="${cyan}${pwd_display}${reset}"
line1+=" ${dim}|${reset} "
line1+="${blue}${model_name}${reset}"
line1+=" ${dim}|${reset} "
line1+="${orange}${used_tokens} / ${total_tokens}${reset}"
line1+=" ${dim}|${reset} "
line1+="${green}${pct_used}% used${reset}"
line1+=" ${dim}|${reset} "
line1+="${cyan}${pct_remain}% remain${reset}"
line1+=" ${dim}|${reset} "
if $thinking_on; then
    line1+="${orange}On${reset}"
else
    line1+="${dim}Off${reset}"
fi
line1+=" ${dim}|${reset} "
line1+="${running_status}"

# ===== Cross-platform OAuth token resolution (from statusline.sh) =====
# Tries credential sources in order: env var → macOS Keychain → Linux creds file → GNOME Keyring
get_oauth_token() {
    local token=""

    # 1. Explicit env var override
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "$CLAUDE_CODE_OAUTH_TOKEN"
        return 0
    fi

    # 2. macOS Keychain
    if command -v security >/dev/null 2>&1; then
        local blob
        blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    # 3. Linux credentials file
    local creds_file="${HOME}/.claude/.credentials.json"
    if [ -f "$creds_file" ]; then
        token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
        if [ -n "$token" ] && [ "$token" != "null" ]; then
            echo "$token"
            return 0
        fi
    fi

    # 4. GNOME Keyring via secret-tool
    if command -v secret-tool >/dev/null 2>&1; then
        local blob
        blob=$(timeout 2 secret-tool lookup service "Claude Code-credentials" 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    echo ""
}

# ===== LINE 2 & 3: Usage limits with progress bars (cached) =====
cache_file="/tmp/claude/statusline-usage-cache.json"
cache_max_age=300  # seconds between API calls
mkdir -p /tmp/claude

is_valid_usage() {
    [ -n "$1" ] && echo "$1" | jq -e '.five_hour' >/dev/null 2>&1
}

needs_refresh=true
usage_data=""

# Load existing cache (if valid)
if [ -f "$cache_file" ]; then
    cached=$(cat "$cache_file" 2>/dev/null)
    if is_valid_usage "$cached"; then
        usage_data="$cached"
        cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
        now=$(date +%s)
        cache_age=$(( now - cache_mtime ))
        [ "$cache_age" -lt "$cache_max_age" ] && needs_refresh=false
    fi
fi

# Fetch fresh data if cache is stale or missing
if $needs_refresh; then
    token=$(get_oauth_token)
    if [ -n "$token" ] && [ "$token" != "null" ]; then
        response=$(curl -s --max-time 5 \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/2.1.69" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
        if is_valid_usage "$response"; then
            usage_data="$response"
            echo "$response" > "$cache_file"
        fi
        # If fetch failed, keep stale usage_data (loaded above)
    fi
fi

# Cross-platform ISO to epoch conversion
# Converts ISO 8601 timestamp (e.g. "2025-06-15T12:30:00Z" or "2025-06-15T12:30:00.123+00:00") to epoch seconds.
# Properly handles UTC timestamps and converts to local time.
iso_to_epoch() {
    local iso_str="$1"

    # Try GNU date first (Linux) — handles ISO 8601 format automatically
    local epoch
    epoch=$(date -d "${iso_str}" +%s 2>/dev/null)
    if [ -n "$epoch" ]; then
        echo "$epoch"
        return 0
    fi

    # BSD date (macOS) - handle various ISO 8601 formats
    local stripped="${iso_str%%.*}"          # Remove fractional seconds (.123456)
    stripped="${stripped%%Z}"                 # Remove trailing Z
    stripped="${stripped%%+*}"                # Remove timezone offset (+00:00)
    stripped="${stripped%%-[0-9][0-9]:[0-9][0-9]}"  # Remove negative timezone offset

    # Check if timestamp is UTC (has Z or +00:00 or -00:00)
    if [[ "$iso_str" == *"Z"* ]] || [[ "$iso_str" == *"+00:00"* ]] || [[ "$iso_str" == *"-00:00"* ]]; then
        # For UTC timestamps, parse with timezone set to UTC
        epoch=$(env TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    else
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    fi

    if [ -n "$epoch" ]; then
        echo "$epoch"
        return 0
    fi

    return 1
}

# Format ISO reset time to compact local time
# Usage: format_reset_time <iso_string> <style: time|datetime|date>
format_reset_time() {
    local iso_str="$1"
    local style="$2"
    [ -z "$iso_str" ] || [ "$iso_str" = "null" ] && return

    # Parse ISO datetime and convert to local time (cross-platform)
    local epoch
    epoch=$(iso_to_epoch "$iso_str")
    [ -z "$epoch" ] && return

    # Format based on style — try BSD date first, fall back to GNU date
    local result=""
    case "$style" in
        time)
            result=$(date -j -r "$epoch" +"%l:%M%p" 2>/dev/null)
            if [ -n "$result" ]; then
                echo "$result" | sed 's/^ //' | tr '[:upper:]' '[:lower:]'
            else
                date -d "@$epoch" +"%l:%M%P" 2>/dev/null | sed 's/^ //'
            fi
            ;;
        datetime)
            result=$(date -j -r "$epoch" +"%b %-d, %l:%M%p" 2>/dev/null)
            if [ -n "$result" ]; then
                echo "$result" | sed 's/  / /g; s/^ //' | tr '[:upper:]' '[:lower:]'
            else
                date -d "@$epoch" +"%b %-d, %l:%M%P" 2>/dev/null | sed 's/  / /g; s/^ //'
            fi
            ;;
        *)
            result=$(date -j -r "$epoch" +"%b %-d" 2>/dev/null)
            if [ -n "$result" ]; then
                echo "$result" | tr '[:upper:]' '[:lower:]'
            else
                date -d "@$epoch" +"%b %-d" 2>/dev/null
            fi
            ;;
    esac
}

# Calculate the expected usage percentage ("pace") at the current moment
# within a rolling window, given the reset epoch and window size in seconds.
#
# Usage: calc_pace_pct <resets_at_epoch> <window_seconds>
# Returns an integer 0-100 (or "" on failure).
calc_pace_pct() {
    local resets_epoch=$1
    local window_secs=$2
    [ -z "$resets_epoch" ] || [ -z "$window_secs" ] && return
    local now_ts
    now_ts=$(date +%s)
    local window_start=$(( resets_epoch - window_secs ))
    local elapsed=$(( now_ts - window_start ))
    [ "$elapsed" -lt 0 ] && elapsed=0
    [ "$elapsed" -gt "$window_secs" ] && elapsed="$window_secs"
    awk "BEGIN {printf \"%.0f\", ($elapsed / $window_secs) * 100}"
}

# Pad column to fixed width (ignoring ANSI codes)
# Usage: pad_column <text_with_ansi> <visible_length> <column_width>
pad_column() {
    local text="$1"
    local visible_len=$2
    local col_width=$3
    local padding=$(( col_width - visible_len ))
    if [ "$padding" -gt 0 ]; then
        printf "%s%*s" "$text" "$padding" ""
    else
        printf "%s" "$text"
    fi
}

line2=""
line3=""
sep=" ${dim}|${reset} "

if [ -n "$usage_data" ] && echo "$usage_data" | jq -e . >/dev/null 2>&1; then
    bar_width=10
    col1w=23
    col2w=22

    # ---- 5-hour (current) ----
    five_hour_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | awk '{printf "%.0f", $1}')
    five_hour_reset_iso=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
    five_hour_reset=$(format_reset_time "$five_hour_reset_iso" "time")

    # Compute pace for 5-hour window (5h = 18000 seconds)
    five_hour_reset_epoch=""
    [ -n "$five_hour_reset_iso" ] && five_hour_reset_epoch=$(iso_to_epoch "$five_hour_reset_iso")
    five_hour_pace=""
    [ -n "$five_hour_reset_epoch" ] && five_hour_pace=$(calc_pace_pct "$five_hour_reset_epoch" 18000)

    five_hour_bar=$(build_bar "$five_hour_pct" "$bar_width" "$five_hour_pace")

    # Pace indicator suffix for the reset line (e.g. "pace 42%")
    five_hour_pace_suffix=""
    five_hour_pace_suffix_plain=""
    if [ -n "$five_hour_pace" ]; then
        five_hour_pace_suffix=" ${dim}pace ${five_hour_pace}%${reset}"
        five_hour_pace_suffix_plain=" pace ${five_hour_pace}%"
    fi

    # Calculate visible length: "current: " + bar + " " + "XX%"
    col1_bar_vis_len=$(( 9 + bar_width + 1 + ${#five_hour_pct} + 1 ))
    col1_bar="${white}current:${reset} ${five_hour_bar} ${cyan}${five_hour_pct}%${reset}"
    col1_bar=$(pad_column "$col1_bar" "$col1_bar_vis_len" "$col1w")

    col1_reset_plain="resets ${five_hour_reset}${five_hour_pace_suffix_plain}"
    col1_reset="${white}resets ${five_hour_reset}${reset}${five_hour_pace_suffix}"
    col1_reset=$(pad_column "$col1_reset" "${#col1_reset_plain}" "$col1w")

    # ---- 7-day (weekly) ----
    seven_day_pct=$(echo "$usage_data" | jq -r '.seven_day.utilization // 0' | awk '{printf "%.0f", $1}')
    seven_day_reset_iso=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty')
    seven_day_reset=$(format_reset_time "$seven_day_reset_iso" "datetime")

    # Compute pace for 7-day window (7d = 604800 seconds)
    seven_day_reset_epoch=""
    [ -n "$seven_day_reset_iso" ] && seven_day_reset_epoch=$(iso_to_epoch "$seven_day_reset_iso")
    seven_day_pace=""
    [ -n "$seven_day_reset_epoch" ] && seven_day_pace=$(calc_pace_pct "$seven_day_reset_epoch" 604800)


    seven_day_bar=$(build_bar "$seven_day_pct" "$bar_width" "$seven_day_pace")

    # Pace indicator suffix for the reset line
    seven_day_pace_suffix=""
    seven_day_pace_suffix_plain=""
    if [ -n "$seven_day_pace" ]; then
        seven_day_pace_suffix=" ${dim}pace ${seven_day_pace}%${reset}"
        seven_day_pace_suffix_plain=" pace ${seven_day_pace}%"
    fi

    col2_bar_vis_len=$(( 8 + bar_width + 1 + ${#seven_day_pct} + 1 ))
    col2_bar="${white}weekly:${reset} ${seven_day_bar} ${cyan}${seven_day_pct}%${reset}"
    col2_bar=$(pad_column "$col2_bar" "$col2_bar_vis_len" "$col2w")

    col2_reset_plain="resets ${seven_day_reset}${seven_day_pace_suffix_plain}"
    col2_reset="${white}resets ${seven_day_reset}${reset}${seven_day_pace_suffix}"
    col2_reset=$(pad_column "$col2_reset" "${#col2_reset_plain}" "$col2w")

    # ---- Extra usage ----
    col3_bar=""
    col3_reset=""
    extra_enabled=$(echo "$usage_data" | jq -r '.extra_usage.is_enabled // false')
    if [ "$extra_enabled" = "true" ]; then
        extra_pct=$(echo "$usage_data" | jq -r '.extra_usage.utilization // 0' | awk '{printf "%.0f", $1}')
        extra_used=$(echo "$usage_data" | jq -r '.extra_usage.used_credits // 0' | awk '{printf "%.2f", $1/100}')
        extra_limit=$(echo "$usage_data" | jq -r '.extra_usage.monthly_limit // 0' | awk '{printf "%.2f", $1/100}')

        # Extra is a monthly window; compute pace using days remaining until next month 1st
        extra_reset_epoch=$(date -v+1m -v1d -v0H -v0M -v0S +%s 2>/dev/null || date -d "$(date +%Y-%m-01) +1 month" +%s 2>/dev/null)
        extra_pace=""
        if [ -n "$extra_reset_epoch" ]; then
            # Days in current month
            days_in_month=$(date +%-d -d "$(date +%Y-%m-01) +1 month -1 day" 2>/dev/null || cal "$(date +%m %Y)" | awk 'NF{f=$NF} END{print f}')
            month_secs=$(( ${days_in_month:-30} * 86400 ))
            extra_pace=$(calc_pace_pct "$extra_reset_epoch" "$month_secs")
        fi

        extra_bar=$(build_bar "$extra_pct" "$bar_width" "$extra_pace")

        # Next month 1st for reset date (cross-platform)
        extra_reset=$(date -v+1m -v1d +"%b %-d" 2>/dev/null || date -d "$(date +%Y-%m-01) +1 month" +"%b %-d" 2>/dev/null)
        extra_reset=$(echo "$extra_reset" | tr '[:upper:]' '[:lower:]')

        extra_pace_suffix=""
        if [ -n "$extra_pace" ]; then
            extra_pace_suffix=" ${dim}pace ${extra_pace}%${reset}"
        fi

        col3_bar="${white}extra:${reset} ${extra_bar} ${cyan}${extra_used}/${extra_limit}${reset}"
        col3_reset="${white}resets ${extra_reset}${reset}${extra_pace_suffix}"
    fi

    # Assemble line 2: bars row
    line2="${col1_bar}${sep}${col2_bar}"
    [ -n "$col3_bar" ] && line2+="${sep}${col3_bar}"

    # Assemble line 3: resets row
    line3="${col1_reset}${sep}${col2_reset}"
    [ -n "$col3_reset" ] && line3+="${sep}${col3_reset}"
fi

# Output all lines
printf "%b" "$line1"
[ -n "$line2" ] && printf "\n%b" "$line2"
[ -n "$line3" ] && printf "\n%b" "$line3"

exit 0