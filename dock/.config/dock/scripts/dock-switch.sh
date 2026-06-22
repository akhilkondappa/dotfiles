#!/usr/bin/env zsh
# dock-switch.sh — Switch to an existing workspace
# Sourced by dock() for cd to work in parent shell

local ticket_id="${1:-}"

# If no argument, fzf picker
if [[ -z "$ticket_id" ]]; then
  local choices=""
  choices+="default\t(general work)\n"
  choices+=$(yq -r '.workspaces[] | select(.status == "active") | .ticket + "\t" + (.summary // "")' "$DOCK_STATE" 2>/dev/null)
  
  ticket_id=$(printf "$choices" \
    | column -t -s$'\t' \
    | fzf --prompt="󰓡 Switch > " --height=10 --reverse --no-info \
    | awk '{print $1}')

  if [[ -z "$ticket_id" ]]; then
    return 0
  fi
fi

ticket_id="${ticket_id:u}"

# Handle "default" workspace switch
if [[ "$ticket_id" == "DEFAULT" ]]; then
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "default" 2>/dev/null || tmux switch-client -l 2>/dev/null
  fi
  echo "default" > "$DOCK_CURRENT"
  echo "󰓡 Switched to default"
  return 0
fi

# Find workspace worktree path
local repo
repo=$(yq -r ".workspaces[] | select(.ticket == \"$ticket_id\") | .repos[0]" "$DOCK_STATE" 2>/dev/null)

if [[ -z "$repo" || "$repo" == "null" ]]; then
  echo "󰅖 No active workspace for $ticket_id"
  return 1
fi

local repo_name="$(basename "$repo")"
local wt_path="$HOME/Repo/worktrees/$ticket_id/$repo_name"

if [[ ! -d "$wt_path" ]]; then
  echo "󰀦  Worktree directory missing: $wt_path"
  return 1
fi

# Switch tmux session (find by ticket prefix since name may include title)
if [[ -n "${TMUX:-}" ]]; then
  local _session
  _session=$(tmux list-sessions -F '#S' 2>/dev/null | grep "^${ticket_id}" | head -1)
  if [[ -n "$_session" ]]; then
    tmux switch-client -t "=$_session"
  else
    tmux new-session -d -s "$ticket_id" -c "$wt_path"
    tmux switch-client -t "=$ticket_id"
  fi
fi

echo "$ticket_id" > "$DOCK_CURRENT"
cd "$wt_path"
echo "󰓡 Switched to $ticket_id"
