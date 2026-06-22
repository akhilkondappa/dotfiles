#!/usr/bin/env zsh
# dock-close.sh — Close a ticket workspace (removes worktrees, keeps branches)
# Sourced by dock() for cd to work in parent shell

local ticket_id="${1:-}"

# If no argument, fzf picker
if [[ -z "$ticket_id" ]]; then
  ticket_id=$(yq -r '.workspaces[] | select(.status == "active") | .ticket + "  " + .summary' "$DOCK_STATE" 2>/dev/null \
    | fzf --prompt="dock close > " --height=10 --reverse --no-info \
    | awk '{print $1}')

  [[ -z "$ticket_id" ]] && return 0
fi

ticket_id="${ticket_id:u}"

# Verify workspace exists
if ! yq -e ".workspaces[] | select(.ticket == \"$ticket_id\")" "$DOCK_STATE" &>/dev/null; then
  echo "󰅖 No workspace found for $ticket_id"
  return 1
fi

# Get repos
local repos
repos=$(yq -r ".workspaces[] | select(.ticket == \"$ticket_id\") | .repos[]" "$DOCK_STATE" 2>/dev/null)

local repo_name wt_path
local has_uncommitted=false

# Check for uncommitted changes
while IFS= read -r repo; do
  repo_name="$(basename "$repo")"
  wt_path="$HOME/Repo/worktrees/$ticket_id/$repo_name"
  if [[ -d "$wt_path" ]] && git -C "$wt_path" status --porcelain 2>/dev/null | grep -q .; then
    echo "󰀦  Uncommitted changes in $repo_name:"
    git -C "$wt_path" status --short
    has_uncommitted=true
  fi
done <<< "$repos"

if [[ "$has_uncommitted" == true ]]; then
  echo ""
  local choice
  choice=$(printf "Close anyway (changes lost)\nCancel" | fzf --prompt="󰀦 > " --height=4 --reverse --no-info)
  [[ "$choice" != "Close anyway (changes lost)" ]] && { echo "Cancelled."; return 0; }
fi

echo "󰅖 Closing $ticket_id..."

# Kill tmux session if it exists (find by ticket prefix since name may include title)
local _session
_session=$(tmux list-sessions -F '#S' 2>/dev/null | grep "^${ticket_id}" | head -1)
if [[ -n "$_session" ]]; then
  tmux kill-session -t "=$_session"
  echo "   tmux session killed"
fi

# Remove worktrees (keep branches)
while IFS= read -r repo; do
  repo_name="$(basename "$repo")"
  wt_path="$HOME/Repo/worktrees/$ticket_id/$repo_name"
  if [[ -d "$wt_path" ]]; then
    git -C "$repo" worktree remove --force "$wt_path" 2>/dev/null \
      && echo "   $repo_name: worktree removed" \
      || echo "   $repo_name: 󰀦 remove failed (clean up manually)"
  else
    echo "   $repo_name: already gone"
  fi
done <<< "$repos"

# Clean up ticket directory
rm -rf "$HOME/Repo/worktrees/$ticket_id" 2>/dev/null

# Update state
yq "del(.workspaces[] | select(.ticket == \"$ticket_id\"))" "$DOCK_STATE" | _dock_write_state

# Clear current ticket if it was this one
if [[ -f "$DOCK_CURRENT" ]] && [[ "$(cat "$DOCK_CURRENT")" == "$ticket_id" ]]; then
  echo "default" > "$DOCK_CURRENT"
fi

echo "󰄬 $ticket_id closed. Branches preserved."
cd "$HOME" 2>/dev/null
