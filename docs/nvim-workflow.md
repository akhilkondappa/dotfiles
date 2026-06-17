# Neovim + Terminal Workflow

How nvim integrates with ghostty, tmux, and shell tools to create a keyboard-driven development environment.

## The Flow: Never Leave the Terminal

```
Ghostty (terminal) → tmux (sessions/panes) → nvim (editor) → back to shell
```

Everything is connected. You can jump from shell to editor to git to file browser without touching a mouse.

## Quick Actions

| What you want to do | How |
|---------------------|-----|
| Open file browser in current dir | `-` (oil.nvim) |
| Find any file in project | `<leader>ff` (telescope/snacks) |
| Search text across project | `<leader>fg` / `<leader>pws` |
| Jump to recent file | `<leader>pr` |
| Jump to pinned file (1-4) | `Ctrl+y/i/n/s` (harpoon) |
| Pin current file | `<leader>a` |
| See pinned files | `Ctrl+e` |
| Open lazygit | `<leader>lg` |
| Open floating terminal | `Cmd+Opt+t` (tmux popup) |
| Switch project/session | `Cmd+k` (sesh) |
| Start a new workspace | `dock work <TICKET>` |

## File Navigation

### Oil.nvim — Edit directories like buffers
- `-` opens parent directory
- `<leader>-` opens in floating window
- Navigate, rename, delete files using normal vim motions
- `q` to close

### Harpoon — Pin your hot files
Mark the 3-4 files you're actively working on. Jump instantly.
- `<leader>a` — add current file
- `Ctrl+e` — show harpoon menu
- `Ctrl+y` / `Ctrl+i` / `Ctrl+n` / `Ctrl+s` — jump to file 1/2/3/4

### Telescope / Snacks Picker
- `<leader>pr` — recent files
- `<leader>pws` — grep word under cursor
- `<leader>pWs` — grep connected WORD under cursor
- `<leader>pk` — search all keymaps
- `<leader>vh` — help pages

## Code Editing

### LSP (Language Server)
- `<leader>f` — format buffer
- `<leader>lr` — restart LSP
- Diagnostics, go-to-definition, references — all via LSP

### Treesitter
Syntax highlighting, text objects, indentation for all languages.

### Blink.cmp
Rust-powered completion engine. Fast, async, no lag.

### Mini.nvim
- `sa` / `sd` / `sr` — surround add/delete/replace
- Auto-pairs for brackets, quotes

## Git Integration

| Key | Action |
|-----|--------|
| `<leader>lg` | Lazygit (full TUI) |
| `<leader>gl` | Lazygit log |
| `<leader>gg` | Fugitive fullscreen |
| `<leader>gbr` | Pick git branch (snacks) |
| `<leader>wl` | List git worktrees |
| `<leader>wc` | Create git worktree |

Gitsigns in-buffer: stage hunks, blame, diff — all inline.

## Window & Buffer Management

| Key | Action |
|-----|--------|
| `<leader>sv` | Split vertical |
| `<leader>sh` | Split horizontal |
| `<leader>se` | Equalize splits |
| `<leader>sx` | Close split |
| `Ctrl+h/j/k/l` | Navigate between nvim splits AND tmux panes seamlessly |
| `<leader>to` | New tab |
| `<leader>tx` | Close tab |
| `<leader>tn/tp` | Next/prev tab |
| `<leader>dB` | Delete buffer |

## Editing Tricks

| Key | Action |
|-----|--------|
| `V + J/K` | Move lines up/down in visual |
| `Ctrl+d/u` | Half-page scroll (centered) |
| `< / >` (visual) | Indent/dedent and reselect |
| `x` | Delete char without yanking |
| `p` (visual) | Paste without losing register |
| `<leader>d` | Delete without yanking |
| `<leader>s` | Find/replace word under cursor |
| `<leader>X` | chmod +x current file |
| `<leader>fp` | Copy filepath to clipboard |
| `<leader>rN` | Rename current file |

## Integration with Terminal Workflow

### Tmux ↔ Nvim (vim-tmux-navigator)
`Ctrl+h/j/k/l` moves between nvim splits AND tmux panes seamlessly. No prefix, no mode switching. You're editing in nvim, press `Ctrl+l`, and you're in the terminal pane next to it.

### Sesh + Dock + Nvim
1. `dock work PEAPP-1234` — creates worktree + tmux session
2. `Cmd+k` — sesh picker to switch between projects
3. Open nvim in any session — harpoon pins are per-project
4. `<leader>lg` — lazygit for commits without leaving

### Shell → Nvim → Shell
- `Cmd+Opt+t` — floating terminal popup over nvim
- `Cmd+Opt+g` — lazygit popup
- `Cmd+Opt+y` — yazi file manager popup
- `-` in nvim — oil file browser (edit dirs as buffers, then `:w` to apply)

### FZF Shell Tools (outside nvim)
| Key | Action |
|-----|--------|
| `Ctrl+t` | Fuzzy file finder (bat preview) |
| `Alt+c` | Fuzzy cd (eza tree preview) |
| `Ctrl+r` | Shell history (atuin) |
| `Alt+s` | Sesh session picker |
| `nlof` | Nvim oldfiles via fzf |
| `nzo` | Zoxide + open in nvim |

## Plugin Overview

| Plugin | Purpose |
|--------|---------|
| oil.nvim | File browser as buffer |
| telescope | Fuzzy finder (files, grep, git) |
| snacks.nvim | Picker, dashboard, lazygit, rename, notifications |
| harpoon | Pin & jump to hot files |
| nvim-tree | Sidebar file explorer |
| treesitter | Syntax highlighting + text objects |
| blink-cmp | Autocompletion |
| mini.nvim | Surround, auto-pairs, AI text objects |
| vim-tmux-navigator | Seamless split navigation |
| gitsigns | Inline git hunks, blame |
| fugitive | Git commands in vim |
| trouble | Diagnostics list |
| undotree | Visual undo history |
| todo-comments | Highlight/search TODOs |
| render-markdown | Live markdown preview |
| showkeys | Display pressed keys |
| catppuccin | Theme (mocha) |

## Theme

Everything uses **Catppuccin Mocha**:
- Ghostty: rosé pine (personal preference for terminal bg)
- Tmux: catppuccin mocha (status bar)
- Neovim: catppuccin mocha (editor)
- Starship: catppuccin mocha palette
