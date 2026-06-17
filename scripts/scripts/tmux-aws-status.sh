#!/bin/bash
# tmux-aws-status.sh — AWS profile + remaining time for active pane
ACTIVE_PANE=$(tmux display-message -p '#{pane_id}' 2>/dev/null)
PANE_FILE="$HOME/.kiro/panes/$ACTIVE_PANE"
[[ ! -f "$PANE_FILE" ]] && exit 0

IFS='|' read -r PROFILE EXPIRY < "$PANE_FILE"
[[ -z "$PROFILE" ]] && exit 0

LABEL="󰸏 $PROFILE"
if [[ -n "$EXPIRY" && "$EXPIRY" != "None" ]]; then
  NOW=$(/bin/date +%s)
  EXPIRY_FIXED=$(echo "$EXPIRY" | sed 's/\([+-][0-9][0-9]\):\([0-9][0-9]\)$/\1\2/')
  EXP=$(/bin/date -j -f "%Y-%m-%dT%H:%M:%S%z" "$EXPIRY_FIXED" +%s 2>/dev/null || echo "")
  if [[ -n "$EXP" ]]; then
    REMAIN=$(( (EXP - NOW) / 60 ))
    if [[ $REMAIN -le 0 ]]; then
      LABEL="$LABEL expired"
    elif [[ $REMAIN -lt 60 ]]; then
      LABEL="$LABEL ${REMAIN}m"
    else
      LABEL="$LABEL $(( REMAIN / 60 ))h$(( REMAIN % 60 ))m"
    fi
  fi
fi
echo "$LABEL"
