#!/usr/bin/env zsh
# dock-menu.sh — fzf action menu
# Sourced by dock() for cd to work in parent shell

local actions=(
  "󰎚 Work on ticket"
  "󰓡 Switch workspace"
  "󰋇 Status"
  "󰅖 Close ticket"
  "󰘥 Help"
)

local sel
sel=$(printf '%s\n' "${actions[@]}" | fzf --prompt="dock > " --height=8 --reverse --no-info)

case "$sel" in
  *"Work"*)
    local tid
    read -r "tid?󰎚 Ticket ID: "
    [[ -n "$tid" ]] && source "$DOCK_SCRIPTS/dock-work.sh" "$tid"
    ;;
  *"Switch"*)
    source "$DOCK_SCRIPTS/dock-switch.sh"
    ;;
  *"Status"*)
    "$DOCK_SCRIPTS/dock-status.sh"
    ;;
  *"Close"*)
    source "$DOCK_SCRIPTS/dock-close.sh"
    ;;
  *"Help"*)
    _dock_help
    ;;
esac
