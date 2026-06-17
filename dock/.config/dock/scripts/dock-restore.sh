#!/usr/bin/env zsh
set -euo pipefail
# dock-restore.sh — Reconcile state file against reality

DOCK_HOME="${DOCK_HOME:-$HOME/.config/dock}"
DOCK_STATE="$DOCK_HOME/workspaces.yaml"

echo "🔧 Reconciling dock state..."

if [[ ! -f "$DOCK_STATE" ]]; then
  echo "workspaces: []" > "$DOCK_STATE"
  echo "   Created fresh state file."
  exit 0
fi

fixed=0

while IFS=$'\t' read -r ticket repo status; do
  local repo_name="$(basename "$repo")"
  local wt_path="$HOME/Repo/worktrees/$ticket/$repo_name"

  if [[ ! -d "$wt_path" ]]; then
    echo "   ⚠️  $ticket: worktree missing at $wt_path"
    echo "      Marking as stale."
    yq -e "(.workspaces[] | select(.ticket == \"$ticket\")).status = \"stale\"" "$DOCK_STATE" > "$DOCK_STATE.tmp.$$" && mv "$DOCK_STATE.tmp.$$" "$DOCK_STATE"
    fixed=$((fixed + 1))
  elif [[ "$status" == "initializing" ]]; then
    echo "   ⚠️  $ticket: stuck in initializing state"
    echo "      [1] Mark active  [2] Remove"
    read -r "choice?      > "
    case "$choice" in
      1) yq -e "(.workspaces[] | select(.ticket == \"$ticket\")).status = \"active\"" "$DOCK_STATE" > "$DOCK_STATE.tmp.$$" && mv "$DOCK_STATE.tmp.$$" "$DOCK_STATE" ;;
      2) yq -e "del(.workspaces[] | select(.ticket == \"$ticket\"))" "$DOCK_STATE" > "$DOCK_STATE.tmp.$$" && mv "$DOCK_STATE.tmp.$$" "$DOCK_STATE" ;;
    esac
    fixed=$((fixed + 1))
  fi
done < <(yq -r '.workspaces[] | [.ticket, .repos[0], .status] | @tsv' "$DOCK_STATE" 2>/dev/null)

if [[ $fixed -eq 0 ]]; then
  echo "   ✓ All workspaces healthy."
else
  echo "   Fixed $fixed issues."
fi
