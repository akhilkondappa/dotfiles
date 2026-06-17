#!/usr/bin/env zsh
# dock.sh — Personal workspace orchestrator (tmux-native)
# Source this file in your .zshrc: source ~/.config/dock/dock.sh

DOCK_HOME="${DOCK_HOME:-$HOME/.config/dock}"
DOCK_SCRIPTS="$DOCK_HOME/scripts"
DOCK_STATE="$DOCK_HOME/workspaces.yaml"
DOCK_HISTORY="$DOCK_HOME/history.yaml"
DOCK_CURRENT="$DOCK_HOME/current-ticket"
DOCK_CONFIG="$DOCK_HOME/config.yaml"

# Branch convention
DOCK_BRANCH_PREFIX="private/akhilk"

# Ensure state files exist
[[ -f "$DOCK_STATE" ]] || echo "workspaces: []" > "$DOCK_STATE"
[[ -f "$DOCK_HISTORY" ]] || echo "history: []" > "$DOCK_HISTORY"
[[ -f "$DOCK_CONFIG" ]] || cat > "$DOCK_CONFIG" <<'EOF'
# dock config
jira_project: PEAPP
repo_base: ~/Repo
EOF

dock() {
  local cmd="${1:-}"
  shift 2>/dev/null || true

  case "$cmd" in
    work)    source "$DOCK_SCRIPTS/dock-work.sh" "$@" ;;
    switch)  source "$DOCK_SCRIPTS/dock-switch.sh" "$@" ;;
    status)  "$DOCK_SCRIPTS/dock-status.sh" "$@" ;;
    close)   source "$DOCK_SCRIPTS/dock-close.sh" "$@" ;;
    menu)    source "$DOCK_SCRIPTS/dock-menu.sh" ;;
    health)  "$DOCK_SCRIPTS/dock-status.sh" --health ;;
    restore) "$DOCK_SCRIPTS/dock-restore.sh" "$@" ;;
    help)    _dock_help ;;
    "")      source "$DOCK_SCRIPTS/dock-menu.sh" ;;
    *)       _dock_ai "$cmd $@" ;;
  esac
}

_dock_help() {
  cat <<'EOF'
dock — workspace orchestrator

  dock work <ticket-id> [--repo <path>] [--offline]   Set up workspace
  dock switch [<ticket-id>]                           Switch workspace (fzf if no arg)
  dock status                                         Show active workspaces
  dock close <ticket-id>                              Teardown workspace
  dock menu                                           fzf action menu
  dock health                                         Check system health
  dock restore                                        Reconcile state vs reality
  dock <anything else>                                AI assist (Kiro headless)
EOF
}

_dock_ai() {
  local prompt="$*"
  if command -v kiro &>/dev/null; then
    timeout 120 kiro chat --no-interactive --trust-all-tools --prompt "$prompt" 2>/dev/null \
      || echo "󰀦  AI request timed out or failed"
  else
    echo "󰀦  Kiro CLI not found. Install from kiro.dev"
  fi
}

# Helper: atomic YAML write
_dock_write_state() {
  local tmp="$DOCK_STATE.tmp.$$"
  cat > "$tmp" && mv "$tmp" "$DOCK_STATE"
}

# Helper: read YAML safely
_dock_read_yaml() {
  local file="$1"
  if [[ ! -f "$file" ]]; then echo "{}"; return 0; fi
  yq '.' "$file" 2>/dev/null || { echo "󰀦  $file is malformed. Run 'dock restore'" >&2; return 1; }
}
