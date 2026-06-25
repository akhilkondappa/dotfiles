# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Auto-launch tmux
if command -v tmux &>/dev/null && [[ -z "$TMUX" ]]; then
  tmux attach -t default 2>/dev/null || tmux new-session -s default
fi

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml" # starship
export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer/" # tldr
export TMUX_CONF="$HOME/.config/tmux/tmux.conf" # tmux

fpath=(~/.zsh/completions $fpath)

# zsh plugins via omz
# path on mac : ~/.oh-my-zsh/custom/plugins/
# then run git clone <link in the to plugin repo>
plugins=(
    git 
    ## with oh-my-zsh and not homebrew
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-system-clipboard
    # zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh
source $HOME/.secrets

#----- Vim Editing modes & keymaps ------ 
set -o vi 

export EDITOR=nvim
export VISUAL=nvim

bindkey -M viins '^P' up-line-or-beginning-search
bindkey -M viins '^N' down-line-or-beginning-search
#----------------------------------------

# Set up FZF key bindings and fuzzy completion
# Keymaps for this is available at https://github.com/junegunn/fzf-git.sh
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"

# Setup fzf previews
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"

# fzf preview for tmux
export FZF_TMUX_OPTS=" -p90%,70% "

# fzf git keybinds use Ctrl+G as prefix (^g^f files, ^g^b branches, etc.)

# -------------------------------
# Initializers and sources
eval "$(gdircolors)"

# wtp (gitworktree plus)
command -v wtp &>/dev/null && eval "$(wtp shell-init zsh)"

# starship 
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"

eval "$(zoxide init zsh)" # zoxide

eval "$(fzf --zsh)" # fzf
source ~/scripts/fzf-git.sh # fzf git
source ~/.config/dock/dock.sh # dock workspace orchestrator

# Atuin configs
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"
bindkey '^r' atuin-search-viins

# ============= Sesh Tmux conf ==============
function sesh-sessions() {
    {
        exec </dev/tty
        exec <&1
        local session
        session=$(sesh list -t -c | fzf --height 50% --border-label ' sesh ' --border --prompt '🛸  ')
        zle reset-prompt > /dev/null 2>&1 || true
        [[ -z "$session" ]] && return
        sesh connect $session
    }
}
zle     -N             sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# -------------------------------

# -------------------ALIAS----------------------
# other Aliases shortcuts
alias c="clear"
alias e="exit"
alias vim="nvim"
alias trl="tmux source-file ~/.config/tmux/tmux.conf && echo 'tmux reloaded'"
alias rsynct="rsync -avh --progress --partial"

# Tmux
alias tmux="tmux -f $TMUX_CONF"
alias a="tmux attach"
alias tns="~/scripts/tmux-sessionizer.sh"

# fzf 
# called from ~/scripts/
alias nlof="~/scripts/fzf_listoldfiles.sh"
# opens documentation through fzf (eg: git,zsh etc.)
alias fman="compgen -c | fzf | xargs man"

# zoxide (called from ~/scripts/)
alias nzo="~/scripts/zoxide_openfiles_nvim.sh"

# Next level ls (options:  --no-filesize --no-time --no-permissions)
alias ls="eza --no-filesize --long --color=always --icons=always --no-user" 

# tree
alias tree="tree -L 3 -a -I '.git' --charset X "
alias dtree="tree -L 3 -a -d -I '.git' --charset X "

# lstr
alias lstr="lstr --icons"

# git aliases
alias gt="git"
alias ga="git add ."
alias gs="git status -s"
alias gc='git commit -m'
alias glog='git log --oneline --graph --all'
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'
alias gcob="git checkout -b"
alias glr="git pull --rebase"
alias grmm="git rebase master"
alias grmn="git rebase main"

alias nvim-scratch="NVIM_APPNAME=nvim-scratch nvim"

# lazygit
alias lg="lazygit"

#terraform
alias tf="terraform"
alias awsfind="source ~/scripts/awsfind"
alias gafzf="source ~/scripts/gafzf"
alias repofind="source ~/scripts/repofind"

# kiro-cli
kc() {
  if [[ -n "$TMUX" ]]; then
    local win_id agent dir prev_name prev=""
    win_id=$(tmux display-message -p "#{window_id}")
    local session_name=$(tmux display-message -p "#{session_name}")
    prev_name=$(tmux display-message -p "#W")
    agent="kiro"
    for i in "$@"; do
      [[ "$prev" == "--agent" ]] && agent="$i"
      prev="$i"
    done
    dir=$(basename "$PWD")
    tmux rename-window -t "$win_id" "${dir}:${agent}"
    tmux set-window-option -t "$win_id" automatic-rename off
    KIRO_TMUX_WINDOW="$win_id" KIRO_TMUX_SESSION="$session_name" kiro-cli chat "$@"
    tmux rename-window -t "$win_id" "$prev_name"
    tmux set-window-option -t "$win_id" automatic-rename on
  else
    kiro-cli chat "$@"
  fi
}

#kubenetes
alias k="kubectl"

# Sync AWS env to per-pane file (for tmux status bar)
_sync_aws_to_pane_file() {
  [[ -z "${TMUX_PANE:-}" ]] && return
  local f="$HOME/.kiro/panes/$TMUX_PANE"
  mkdir -p "$HOME/.kiro/panes"
  if [[ -n "${AWS_PROFILE:-}" ]]; then
    echo "${AWS_PROFILE}|${AWS_CREDENTIAL_EXPIRATION:-}" > "$f"
  else
    rm -f "$f"
  fi
}
precmd_functions+=(_sync_aws_to_pane_file)

# ---------------------------------------

# brew installations (new mac systems brew path: opt/homebrew , not usr/local )
# source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

typeset -U PATH

export PATH="$HOME/.local/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/eakhkon/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/eakhkon/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/eakhkon/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/eakhkon/google-cloud-sdk/completion.zsh.inc'; fi
