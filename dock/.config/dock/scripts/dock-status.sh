#!/usr/bin/env zsh
set -euo pipefail
# dock-status.sh — Show active workspaces with health check

DOCK_HOME="${DOCK_HOME:-$HOME/.config/dock}"
DOCK_STATE="$DOCK_HOME/workspaces.yaml"

if [[ "${1:-}" == "--health" ]]; then
  echo "󰛨 System Health"
  echo "   State file: $([ -f "$DOCK_STATE" ] && echo "✓" || echo "❌ missing")"
  echo "   git: $(command -v git &>/dev/null && echo "✓" || echo "❌ not found")"
  echo "   fzf: $(command -v fzf &>/dev/null && echo "✓" || echo "❌ not found")"
  echo "   tmux: $([ -n "${TMUX:-}" ] && echo "✓ connected" || echo "󰀦 not in tmux")"
  echo "   yq: $(command -v yq &>/dev/null && echo "✓" || echo "❌ not found")"
  echo "   sesh: $(command -v sesh &>/dev/null && echo "✓" || echo "󰀦 not found")"
  exit 0
fi

if [[ ! -f "$DOCK_STATE" ]]; then
  echo "No active workspaces."
  exit 0
fi

count=$(yq '.workspaces | length' "$DOCK_STATE" 2>/dev/null || echo 0)

if [[ "$count" == "0" ]]; then
  echo "No active workspaces."
  exit 0
fi

echo "󰎚 Active Workspaces"
echo ""

for i in $(seq 0 $((count - 1))); do
  ticket=$(yq -r ".workspaces[$i].ticket" "$DOCK_STATE")
  ws_status=$(yq -r ".workspaces[$i].status" "$DOCK_STATE")
  summary=$(yq -r ".workspaces[$i].summary // \"\"" "$DOCK_STATE")

  # Check tmux session
  local tmux_status="○"
  tmux has-session -t "$ticket" 2>/dev/null && tmux_status="●"

  [[ ${#summary} -gt 40 ]] && summary="${summary:0:37}..."

  printf "  %s %-12s %-12s %s\n" "$tmux_status" "$ticket" "$ws_status" "${summary:-(no summary)}"
done

echo ""
