# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml" # starship
export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer/" # tldr

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

# unbind ctrl g in terminal
bindkey -r "^G"

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

# Atuin configs
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"
bindkey '^r' atuin-search-viins

# -------------------------------

# -------------------ALIAS----------------------
# other Aliases shortcuts
alias c="clear"
alias e="exit"
alias vim="nvim"

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

#kubenetes
alias k="kubectl"
# ---------------------------------------

# brew installations (new mac systems brew path: opt/homebrew , not usr/local )
# source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

typeset -U PATH

export PATH="$HOME/.local/bin:$PATH"
