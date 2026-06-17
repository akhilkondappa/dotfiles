#!/bin/bash
# tmux-status-right.sh — k8s context + AWS profile for active pane

parts=()

# K8s context
CTX=$(kubectl config current-context 2>/dev/null)
if [[ -n "$CTX" ]]; then
  NS=$(kubectl config view --minify --output 'jsonpath={.contexts[0].context.namespace}' 2>/dev/null)
  [[ -n "$NS" ]] && CTX="$CTX($NS)"
  parts+=("󱃾 $CTX")
fi

# AWS profile from active pane's file
ACTIVE_PANE=$(tmux display-message -p '#{pane_id}' 2>/dev/null)
PANE_FILE="$HOME/.kiro/panes/$ACTIVE_PANE"
if [[ -f "$PANE_FILE" ]]; then
  IFS='|' read -r PROFILE EXPIRY < "$PANE_FILE"
  if [[ -n "$PROFILE" ]]; then
    LABEL="󰸏 $PROFILE"
    if [[ -n "$EXPIRY" && "$EXPIRY" != "None" ]]; then
      NOW=$(date +%s)
      # BSD date needs +0530 not +05:30
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
    parts+=("$LABEL")
  fi
fi

# Output with separator
echo "${parts[0]:-}$([ ${#parts[@]} -gt 1 ] && echo " │ ${parts[1]}")"
