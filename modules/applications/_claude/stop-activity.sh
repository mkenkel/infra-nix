#!/usr/bin/env bash
# Stop hook — Claude finished its turn; mark session as idle with current timestamp.
# Reads the hook JSON from stdin, extracts session_id, and writes a state file.
# Also stores the project_dir so the statusline can identify agent team peers.

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // "default"' 2>/dev/null | tr -cd '[:alnum:]-_')
[ -z "$session_id" ] && session_id="default"

project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""' 2>/dev/null)

now_epoch=$(date +%s)
mkdir -p /tmp/claude
printf '{"status":"idle","idle_since":%s,"project_dir":"%s"}' "$now_epoch" "$project_dir" \
    > "/tmp/claude/activity-state-${session_id}.json"