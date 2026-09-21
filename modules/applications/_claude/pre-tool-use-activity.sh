#!/usr/bin/env bash
# PreToolUse hook — Claude is actively processing; mark session as running.
# Reads the hook JSON from stdin, extracts session_id, and writes a state file.
# Also stores the project_dir so the statusline can identify agent team peers.

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // "default"' 2>/dev/null | tr -cd '[:alnum:]-_')
[ -z "$session_id" ] && session_id="default"

project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""' 2>/dev/null)

mkdir -p /tmp/claude
printf '{"status":"running","idle_since":0,"project_dir":"%s"}' "$project_dir" \
    > "/tmp/claude/activity-state-${session_id}.json"
