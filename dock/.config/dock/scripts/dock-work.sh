#!/usr/bin/env zsh
# dock-work.sh — Set up a worktree + tmux session for a ticket
# Sourced by dock() for cd to work in parent shell

local ticket_id=""
local repo_path=""
local offline=false

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)    repo_path="$2"; shift 2 ;;
    --offline) offline=true; shift ;;
    *)         ticket_id="$1"; shift ;;
  esac
done

local jira_base="https://ericsson-enterprise.atlassian.net"
local jira_project="PEAWS"
local summary=""

# If no ticket ID given, fetch sprint tickets via fzf
if [[ -z "$ticket_id" ]]; then
  if [[ -z "${JIRA_EMAIL:-}" || -z "${JIRA_TOKEN:-}" ]]; then
    echo "󰅖 JIRA_EMAIL and JIRA_TOKEN required. Use 'dock work <ticket-id> --offline' instead."
    return 1
  fi

  echo "󰎚 Fetching current sprint tickets..."
  local jql="project=$jira_project AND sprint in openSprints() AND assignee=currentUser() ORDER BY priority DESC"
  local tickets_json
  tickets_json=$(timeout 15 curl -s \
    -u "${JIRA_EMAIL}:${JIRA_TOKEN}" \
    -G --data-urlencode "jql=$jql" \
    --data-urlencode "fields=summary,status,priority" \
    --data-urlencode "maxResults=20" \
    "$jira_base/rest/api/3/search/jql" 2>/dev/null)

  if [[ -z "$tickets_json" ]] || ! echo "$tickets_json" | jq -e '.issues' &>/dev/null; then
    echo "󰅖 Failed to fetch tickets. Check JIRA_EMAIL/JIRA_TOKEN or network."
    return 1
  fi

  local ticket_count
  ticket_count=$(echo "$tickets_json" | jq '.issues | length')
  if [[ "$ticket_count" == "0" ]]; then
    echo "   No tickets in current sprint."
    return 0
  fi

  local selection
  selection=$(echo "$tickets_json" | jq -r '.issues[] | "\(.key)\t\(.fields.priority.name // "-")\t\(.fields.status.name)\t\(.fields.summary)"' \
    | column -t -s$'\t' \
    | fzf --prompt="󰎚 Pick ticket > " --height=15 --reverse --no-info --ansi)

  [[ -z "$selection" ]] && return 0
  ticket_id=$(echo "$selection" | awk '{print $1}')
fi

# Normalize ticket ID
ticket_id="${ticket_id:u}"

# Determine repo
if [[ -z "$repo_path" ]]; then
  if ! git rev-parse --git-dir &>/dev/null 2>&1; then
    echo "󰅖 Not a git repo. Use --repo <path> or cd to a repo first."
    return 1
  fi
  repo_path="$(git rev-parse --show-toplevel)"
fi
repo_path="${repo_path/#\~/$HOME}"
repo_path="$(cd "$repo_path" 2>/dev/null && pwd)" || { echo "󰅖 Repo path not found: $repo_path"; return 1; }

local repo_name="$(basename "$repo_path")"
local branch="$DOCK_BRANCH_PREFIX/$ticket_id"
local wt_dest="$HOME/Repo/worktrees/$ticket_id/$repo_name"

# Check if this repo already has a worktree for this ticket
if yq -e ".workspaces[] | select(.ticket == \"$ticket_id\") | .repos[] | select(. == \"$repo_path\")" "$DOCK_STATE" &>/dev/null; then
  if [[ -d "$wt_dest" ]]; then
    echo "󰀦  Already docked: $repo_name for $ticket_id. Switching."
    cd "$wt_dest"
    if [[ -n "${TMUX:-}" ]]; then
      local existing_session
      existing_session=$(tmux list-sessions -F '#S' 2>/dev/null | grep "^${ticket_id}" | head -1)
      if [[ -n "$existing_session" ]]; then
        tmux switch-client -t "=$existing_session"
      else
        # No session exists — create one with proper naming
        local _summary
        _summary=$(yq -r ".workspaces[] | select(.ticket == \"$ticket_id\") | .summary // \"\"" "$DOCK_STATE" 2>/dev/null)
        local _sname="$ticket_id"
        if [[ -n "$_summary" ]]; then
          local _stitle
          _stitle=$(printf '%s' "$_summary" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//' | cut -c1-10 | sed 's/-$//')
          [[ -n "$_stitle" ]] && _sname="${ticket_id}/${_stitle}"
        fi
        tmux new-session -d -s "$_sname" -c "$wt_dest"
        tmux switch-client -t "=$_sname"
      fi
    fi
    return 0
  fi
fi

# Fetch ticket summary (unless offline or already have it from fzf)
if [[ "$offline" == false && -z "$summary" ]]; then
  local issue_json
  issue_json=$(timeout 10 curl -s \
    -u "${JIRA_EMAIL}:${JIRA_TOKEN}" \
    "$jira_base/rest/api/3/issue/$ticket_id?fields=summary" 2>/dev/null || true)

  if [[ -n "$issue_json" ]]; then
    summary=$(echo "$issue_json" | jq -r '.fields.summary // empty' 2>/dev/null)
  fi

  if [[ -z "$summary" ]]; then
    echo "󰀦  Could not fetch ticket details. Continuing offline."
  else
    echo "󰎚 $ticket_id: $summary"
  fi
fi

# Create worktree
echo "   Branch: $branch"
cd "$repo_path" || { echo "󰅖 Cannot cd to $repo_path"; return 1; }
git fetch origin --quiet 2>/dev/null

mkdir -p "$(dirname "$wt_dest")"

if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
  local existing_wt
  existing_wt=$(git worktree list | grep "\[$branch\]" | awk '{print $1}')
  if [[ -n "$existing_wt" && -d "$existing_wt" ]]; then
    echo "   Worktree exists at $existing_wt"
    wt_dest="$existing_wt"
  else
    git worktree add "$wt_dest" "$branch" || { echo "󰅖 worktree add failed"; return 1; }
  fi
else
  git worktree add "$wt_dest" -b "$branch" || { echo "󰅖 worktree add failed"; return 1; }
fi

# Write state
local workspace_exists
if yq -e ".workspaces[] | select(.ticket == \"$ticket_id\")" "$DOCK_STATE" &>/dev/null; then
  workspace_exists="yes"
else
  workspace_exists="no"
fi

if [[ "$workspace_exists" == "yes" ]]; then
  yq "(.workspaces[] | select(.ticket == \"$ticket_id\") | .repos) += [\"$repo_path\"]" \
    "$DOCK_STATE" | _dock_write_state
else
  yq --arg ticket "$ticket_id" --arg summary "${summary:-}" --arg created "$(date -u +%FT%TZ)" \
    '.workspaces += [{"ticket": $ticket, "summary": $summary, "status": "active", "created": $created, "repos": ["'"$repo_path"'"]}]' \
    "$DOCK_STATE" | _dock_write_state
fi

echo "$ticket_id" > "$DOCK_CURRENT"

# Register with zoxide so sesh can find it
command -v zoxide &>/dev/null && zoxide add "$wt_dest"

# Build session name: TICKET/short-title (10 chars max)
# Note: tmux converts ':' to '_', so we use '/' as separator
local session_name="$ticket_id"
if [[ -n "$summary" ]]; then
  local short_title
  short_title=$(printf '%s' "$summary" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//' | cut -c1-10 | sed 's/-$//')
  [[ -n "$short_title" ]] && session_name="${ticket_id}/${short_title}"
fi

# Tmux session
if [[ -n "${TMUX:-}" ]]; then
  if ! tmux has-session -t "=$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name" -c "$wt_dest"
    tmux switch-client -t "=$session_name"
  else
    tmux switch-client -t "=$session_name"
  fi
elif command -v tmux &>/dev/null; then
  if ! tmux has-session -t "=$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name" -c "$wt_dest"
  fi
  echo "   tmux session '$session_name' created. Attach with: tmux attach -t '=$session_name'"
fi

echo "   Worktree: $wt_dest"
echo "󰄬 $ticket_id ready. ($repo_name)"
cd "$wt_dest"
