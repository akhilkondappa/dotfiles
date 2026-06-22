# Dotfiles Reference

## Stow Packages

All configs live in `~/sidekicks/dotfiles/` and are symlinked to `~` via GNU Stow.

```bash
cd ~/sidekicks/dotfiles && stow -t ~ ghostty tmux nvim zsh starship atuin wezterm sesh scripts dock
```

| Package | Symlinks to |
|---------|-------------|
| ghostty | `~/.config/ghostty` |
| tmux | `~/.config/tmux` |
| nvim | `~/.config/nvim` |
| zsh | `~/.zshrc`, `~/.zprofile` |
| starship | `~/.config/starship` |
| atuin | `~/.config/atuin` |
| sesh | `~/.config/sesh` |
| wezterm | `~/.config/wezterm` |
| scripts | `~/scripts` |
| dock | `~/.config/dock` |

---

## Ghostty Keybindings

### Ghostty-native (no tmux needed)

| Key | Action |
|-----|--------|
| `Ctrl+Space > [` | Reload config |
| `Cmd+Shift+,` | Reload config |
| `Cmd+i` | Toggle inspector |
| `Cmd+n` | New Ghostty window |
| `Ctrl+Space > c` | New tab (needs titlebar=tabs) |
| `Ctrl+Space > x` | Close surface |
| `Ctrl+Space > \` | Split right |
| `Ctrl+Space > -` | Split down |
| `Ctrl+Space > e` | Equalize splits |
| `Ctrl+Space > h/j/k/l` | Navigate splits |
| `Ctrl+Space > 1-9` | Jump to tab |

### Ghostty → Tmux (primary workflow)

#### Splits

| Key | Action |
|-----|--------|
| `Cmd+\` | Split right |
| `Cmd+Opt+\` | Split down |

#### Pane management

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Navigate panes (vim-tmux-navigator, no prefix) |
| `Cmd+Opt+h/j/k/l` | Resize pane |
| `Cmd+Enter` | Zoom/maximize pane |
| `Cmd+x` | Close pane |
| `Cmd+Opt+s` | Swap pane (pick target) |

#### Windows (tabs)

| Key | Action |
|-----|--------|
| `Cmd+t` | New window |
| `Cmd+[` / `Cmd+]` | Previous/next window |
| `Cmd+Opt+[` / `Cmd+Opt+]` | Move window left/right |
| `Cmd+Opt+x` | Close window |
| `Cmd+1-9` | Jump to window by number |

#### Copy mode & Search

| Key | Action |
|-----|--------|
| `Cmd+u` | Enter copy mode (then use vi keys to scroll/search) |
| `Cmd+f` | Enter search mode |

#### Sessions & Dock

| Key | Action |
|-----|--------|
| `Cmd+k` | Sesh session picker (fzf) |
| `Alt+j` | Dock menu (inline) |
| `Alt+Shift+j` | Dock menu (tmux popup) |

### Ghostty Features

- **Rosé Pine** theme with 85% opacity + background blur
- **Window state restore** — reopens layout on restart (`window-save-state = always`)
- **Copy on select** — selected text auto-copies to clipboard
- **Clipboard read/write** — OSC 52 enabled (allows kiro-cli Ctrl+Y copy)
- **Hidden titlebar** — maximizes screen real estate
- **Option as Alt** — proper terminal Alt key on macOS
- **Shaders available** — uncomment in config: CRT, retro-terminal, bloom

---

## Tmux Keybindings

Prefix: `Ctrl+b`

### Panes

| Key | Action |
|-----|--------|
| `prefix + \|` | Split right |
| `prefix + -` | Split down |
| `prefix + h/j/k/l` | Resize pane (repeatable, 5 units) |
| `prefix + m` | Zoom/maximize pane |
| `prefix + x` | Kill pane |
| `prefix + s` | Swap pane (display-panes picker) |
| `Ctrl+h/j/k/l` | Navigate panes (vim-tmux-navigator, no prefix) |

### Windows

| Key | Action |
|-----|--------|
| `prefix + c` | New window |
| `prefix + &` | Kill window |
| `prefix + <` / `prefix + >` | Move window left/right |
| `Alt+Shift+H` / `Alt+Shift+L` | Previous/next window (no prefix) |

### Sessions

| Key | Action |
|-----|--------|
| `prefix + K` | Sesh fzf picker |
| `prefix + T` | Sesh gum picker (simple) |
| `prefix + o` | SessionX picker |
| `prefix + n` | New session (prompts for name) |
| `prefix + f` | Tmux-sessionizer |

Sesh fzf picker controls:
- `Ctrl+a` — show all
- `Ctrl+t` — tmux sessions only
- `Ctrl+g` — config sessions
- `Ctrl+x` — zoxide directories
- `Ctrl+f` — find directories
- `Ctrl+d` — kill selected session

### Popups (floating windows)

| Key | Action |
|-----|--------|
| `prefix + Ctrl+y` | Yazi file manager (90%) |
| `prefix + Ctrl+t` | Floating terminal (80%) |
| `prefix + Ctrl+g` | Lazygit (90%) |
| `prefix + Ctrl+d` | Dock menu (80x50%) |
| `prefix + Ctrl+m` | Music player — rmpc (95%) |
| `prefix + d` | Config quick-edit menu |

### Copy mode (vim keys)

| Key | Action |
|-----|--------|
| `prefix + v` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection |

### Utility

| Key | Action |
|-----|--------|
| `prefix + r` | Reload tmux config |

### Plugins

- `christoomey/vim-tmux-navigator` — seamless Ctrl+h/j/k/l between nvim and tmux
- `catppuccin/tmux` — Catppuccin Mocha status bar theme
- `tmux-plugins/tmux-online-status` — online/offline indicator
- `tmux-plugins/tmux-battery` — battery status (commented out)
- `omerxx/tmux-sessionx` — session picker (`prefix + o`)
- TPM at `~/.config/tmux/.tmux/plugins/tpm` — install plugins with `prefix + I`

---

## Neovim Keybindings

Leader: `Space`

### Movement & Editing

| Key | Action |
|-----|--------|
| `V + J/K` | Move lines up/down in visual |
| `Ctrl+d/u` | Half-page down/up (cursor centered) |
| `< / >` (visual) | Indent/dedent and reselect |
| `x` | Delete char without yanking |
| `p` (visual) | Paste without losing register |
| `leader + d` | Delete without yanking |
| `leader + s` | Find/replace word under cursor globally |
| `J` (normal) | Join lines (cursor stays put) |

### Splits & Tabs

| Key | Action |
|-----|--------|
| `leader + sv` | Split vertical |
| `leader + sh` | Split horizontal |
| `leader + se` | Equalize splits |
| `leader + sx` | Close split |
| `leader + to` | New tab |
| `leader + tx` | Close tab |
| `leader + tn/tp` | Next/previous tab |
| `leader + tf` | Current buffer in new tab |
| `Ctrl+h/j/k/l` | Navigate splits (vim-tmux-navigator) |

### LSP & Utility

| Key | Action |
|-----|--------|
| `leader + f` | Format buffer (LSP) |
| `leader + lr` | Restart LSP |
| `leader + re` | Restart Neovim |
| `leader + fp` | Copy filepath to clipboard |
| `leader + X` | Make file executable (chmod +x) |
| `Ctrl+c` (normal) | Clear search highlight |
| `leader + leader` | Source current file |

### Plugins

| Plugin | Keys / Usage |
|--------|-------------|
| **telescope** | `leader + ff` files, `leader + fg` grep, `leader + fb` buffers, `leader + fh` help |
| **harpoon** | `leader + a` add, `leader + e` menu, `Ctrl+1-4` jump |
| **oil** | `-` open parent directory as buffer |
| **nvim-tree** | `leader + ee` toggle file tree |
| **trouble** | `leader + xx` workspace diagnostics |
| **undotree** | `leader + u` toggle undo history |
| **todo-comments** | `leader + td` show TODOs |
| **showkeys** | Displays pressed keys on screen |
| **blink-cmp** | Auto-completion (Rust-powered, replaces nvim-cmp) |
| **snacks** | Dashboard, notifications, indent guides |
| **mini** | Surround (`sa/sd/sr`), auto-pairs, AI text objects |
| **render-markdown** | Live markdown preview in buffer |
| **vim-tmux-navigator** | Seamless split navigation with tmux |
| **lazydev** | Lua LSP workspace library support |
| **treesitter** | Syntax highlighting, text objects, incremental selection |

### Neovim Options

- Relative line numbers
- 4-space indentation (expandtab)
- Persistent undo (`~/.local/share/nvim/undodir`)
- No swap/backup files
- Split right and below
- Scroll offset of 8 lines
- System clipboard integration
- Yank highlighting

---

## Dock — Workspace Orchestrator

### Commands

```bash
dock work <TICKET-ID>              # Create worktree + tmux session
dock work                          # Fetch sprint tickets from Jira, pick with fzf
dock work PEAWS-1234 --offline     # Skip Jira API
dock work PEAWS-1234 --repo ~/Repo/svc  # Specify repo explicitly

dock switch                        # fzf picker for active workspaces
dock switch PEAWS-1234             # Direct switch

dock status                        # List workspaces (● = tmux session alive)
dock close                         # fzf pick workspace to close
dock close PEAWS-1234              # Close specific workspace

dock menu                          # fzf action menu
dock health                        # Check git, fzf, tmux, yq, sesh
dock restore                       # Fix stale/orphaned state entries
dock <anything else>               # AI assist via Kiro CLI
```

### What `dock work` does

1. Fetches ticket summary from Jira (optional)
2. Creates git worktree at `~/Repo/worktrees/<TICKET>/<repo-name>/`
3. Creates branch `private/akhilk/<TICKET>`
4. Creates tmux session named `<TICKET>/<short-title>` (e.g., `PEAWS-1234/fix-bug-in`)
5. Switches to that session and cds into worktree

### State files

| File | Purpose |
|------|---------|
| `~/.config/dock/workspaces.yaml` | Active workspace registry |
| `~/.config/dock/history.yaml` | Closed workspace log |
| `~/.config/dock/current-ticket` | Currently active ticket ID |
| `~/.config/dock/config.yaml` | Project/branch settings |

### Requirements

- `git`, `fzf`, `yq`, `jq`, `tmux`, `sesh`
- `JIRA_EMAIL` + `JIRA_TOKEN` env vars (for Jira integration)

---

## Sesh — Session Manager

Sesh is the fast session switcher. Dock creates workspaces, sesh navigates between them.

### Config (`~/.config/sesh/sesh.toml`)

- Wildcard patterns for `~/Repo/worktrees/**`, `~/Repo/dev/**`, `~/sidekicks/**`
- Default startup: `nvim`
- Preview: `eza --all --git --icons`

### Usage

| Trigger | Where | Action |
|---------|-------|--------|
| `prefix + K` | tmux | Full fzf picker (sessions, configs, zoxide, find) |
| `prefix + T` | tmux | Gum picker (simple) |
| `Alt+s` | shell | Quick session connect from prompt |
| `sesh connect <path>` | CLI | Connect/create session at path |
| `sesh list` | CLI | List all sessions + zoxide dirs |

### Picker controls (`prefix + K`)

| Key | Filters to |
|-----|-----------|
| `Ctrl+a` | All (sessions + zoxide + configs) |
| `Ctrl+t` | Tmux sessions only |
| `Ctrl+g` | Config sessions only |
| `Ctrl+x` | Zoxide directories |
| `Ctrl+f` | Find directories (fd) |
| `Ctrl+d` | Kill selected session |

### Integration with Dock

- `dock work` creates worktree → registers with zoxide → creates tmux session `<TICKET>/<short-title>`
- `dock switch` is deprecated — use sesh picker instead
- `dock close` tears down worktree + session (sesh has no lifecycle management)

---


## Shell Aliases & Tools

### Quick aliases

| Alias | Expands to |
|-------|-----------|
| `c` | `clear` |
| `e` | `exit` |
| `vim` | `nvim` |
| `lg` | `lazygit` |
| `tr` | Reload tmux config |
| `a` | `tmux attach` |
| `tns` | Tmux-sessionizer script |
| `k` | `kubectl` |
| `tf` | `terraform` |
| `rsynct` | `rsync -avh --progress --partial` |
| `nvim-scratch` | Neovim with scratch config |

### Git aliases

| Alias | Command |
|-------|---------|
| `ga` | `git add .` |
| `gs` | `git status -s` |
| `gc "msg"` | `git commit -m "msg"` |
| `glog` | `git log --oneline --graph --all` |
| `gcob <branch>` | `git checkout -b <branch>` |
| `glr` | `git pull --rebase` |
| `grmm` / `grmn` | `git rebase master/main` |
| `gh-create` | Create private GitHub repo + push + open |

### FZF-powered tools

| Trigger | What it does |
|---------|-------------|
| `Ctrl+t` | Fuzzy file finder (bat preview) |
| `Alt+c` | Fuzzy cd into directories (eza tree preview) |
| `Ctrl+r` | Atuin shell history search |
| `Alt+s` | Sesh session picker (from shell prompt) |
| `nlof` | fzf through neovim oldfiles |
| `nzo` | Zoxide + open in nvim |
| `fman` | fzf man pages |
| `Ctrl+g` | fzf-git (branches, commits, tags, stashes) |

### Navigation & Tools

| Tool | Usage |
|------|-------|
| `z <partial>` | Zoxide smart cd (learns from usage) |
| `awsfind` | AWS resource finder script |
| `gafzf` | Git add with fzf file picker |
| `repofind` | Repository finder script |
| `wtp` | Git worktree plus (if installed) |

### Shell features

- **Vi mode** (`set -o vi`) — vim keybindings in shell
- `Ctrl+P/N` — up/down history search in insert mode
- **Starship** prompt with vi-mode indicator
- **zsh-autosuggestions** — fish-style suggestions
- **zsh-syntax-highlighting** — command validation highlighting
- **zsh-system-clipboard** — vi mode uses system clipboard

---

## File Locations

```
~/.config/ghostty/config        → ghostty terminal config
~/.config/tmux/tmux.conf        → tmux config
~/.config/nvim/                 → neovim config (lazy.nvim)
~/.config/dock/                 → dock workspace orchestrator
~/.config/starship/starship.toml → prompt theme
~/.config/atuin/config.toml     → shell history config
~/.zshrc                        → shell config
~/.zprofile                     → login shell env
~/scripts/                      → utility scripts
```

---

## First-time Setup

```bash
cd ~/sidekicks/dotfiles
./install.sh                    # Installs homebrew, oh-my-zsh, packages, stows everything

# After install:
tmux                            # Start tmux
prefix + I                      # Install tmux plugins via TPM
nvim                            # Open nvim, Lazy will auto-install plugins
```

## Maintenance

```bash
# Re-stow after pulling changes
cd ~/sidekicks/dotfiles && stow -t ~ ghostty tmux nvim zsh starship atuin sesh scripts dock

# Update tmux plugins
prefix + U

# Update nvim plugins
nvim → :Lazy update

# Reload configs without restart
tr                              # tmux reload
Cmd+Shift+,                     # ghostty reload
:so (in nvim)                   # source current file
```
