# Dotfiles

My macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Features

### Terminal
- **[WezTerm](https://wezfurlong.org/wezterm/)** — GPU-accelerated terminal with rose-pine theme, JetBrainsMono Nerd Font, transparency + blur
- **[Zsh](https://www.zsh.org/)** + **[oh-my-zsh](https://ohmyz.sh/)** — shell with vi mode, custom keybindings, and plugins
- **[Starship](https://starship.rs/)** — cross-shell prompt with git status, language versions, and vi-mode indicator
- **[Atuin](https://atuin.sh/)** — magical shell history with sync, search bound to `Ctrl+R`

### Editor
- **[Neovim](https://neovim.io/)** — full IDE setup with [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager
  - LSP (Mason + lspconfig) for language intelligence
  - Treesitter for syntax highlighting
  - Telescope for fuzzy finding
  - Harpoon for file navigation
  - nvim-cmp for autocompletion
  - Oil, nvim-tree for file management
  - Git integration (gitsigns, git-worktree)
  - Lualine statusline, noice UI, snacks
  - Auto-session, trouble, todo-comments, and more

### Shell Enhancements
- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder with bat/eza previews, fzf-git integration
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd` command
- **[eza](https://eza.rocks/)** — modern `ls` replacement with icons
- **[bat](https://github.com/sharkdp/bat)** — `cat` with syntax highlighting
- **[fd](https://github.com/sharkdp/fd)** — fast `find` alternative
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** — fast `grep` alternative
- **[lazygit](https://github.com/jesseduffield/lazygit)** — terminal UI for git
- **[wtp](https://github.com/satococoa/wtp)** — git worktree plus

### oh-my-zsh Plugins
- `git` — git aliases and functions
- `zsh-syntax-highlighting` — command syntax highlighting
- `zsh-system-clipboard` — vi-mode system clipboard integration

### Shell Aliases
| Alias | Command | Description |
|-------|---------|-------------|
| `c` | `clear` | Clear terminal |
| `e` | `exit` | Exit shell |
| `vim` | `nvim` | Neovim |
| `lg` | `lazygit` | Lazygit |
| `ls` | `eza --long --icons` | Pretty file listing |
| `tree` | `tree -L 3 -a` | Directory tree |
| `gs` | `git status -s` | Short git status |
| `ga` | `git add .` | Stage all |
| `gc` | `git commit -m` | Commit with message |
| `glog` | `git log --oneline --graph --all` | Pretty git log |
| `nlof` | fzf oldfiles script | Fuzzy find recent files |
| `nzo` | zoxide + nvim script | Zoxide jump and open in nvim |
| `fman` | fzf + man | Fuzzy find man pages |

## Repository Structure

```
dotfiles/
├── install.sh                              # Automated setup script
├── wezterm/.config/wezterm/wezterm.lua     # WezTerm config
├── zsh/.zshrc                              # Zsh config (oh-my-zsh, aliases, keybindings)
├── zsh/.zprofile                           # Zsh profile (PATH, env vars)
├── starship/.config/starship/starship.toml # Starship prompt config
├── atuin/.config/atuin/config.toml         # Atuin shell history config
├── nvim/.config/nvim/                      # Neovim config (lazy.nvim)
│   ├── init.lua
│   ├── lua/eakhkon/core/                   # Core options and keymaps
│   ├── lua/eakhkon/plugins/                # Plugin configs
│   └── after/ftplugin/                     # Filetype-specific settings
└── scripts/scripts/                        # Utility scripts
    ├── fzf-git.sh                          # fzf git integration
    ├── fzf_listoldfiles.sh                 # fzf recent files
    └── zoxide_openfiles_nvim.sh            # zoxide + nvim opener
```

## Quick Setup

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Manual Setup

### Prerequisites

1. **Xcode CLI tools**
   ```bash
   xcode-select --install
   ```

2. **Homebrew**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

3. **oh-my-zsh**
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

4. **oh-my-zsh plugins**
   ```bash
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   git clone https://github.com/kutsan/zsh-system-clipboard.git \
     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-system-clipboard
   ```

5. **Brew packages**
   ```bash
   brew tap satococoa/tap
   brew install coreutils stow fzf bat fd zoxide lua ripgrep eza \
     git lazygit neovim starship tree-sitter tree node nvm atuin \
     satococoa/tap/wtp
   ```

6. **Casks**
   ```bash
   brew install --cask wezterm font-hack-nerd-font font-jetbrains-mono-nerd-font
   ```

### Stow Dotfiles

```bash
cd ~/dotfiles
mkdir -p ~/.config
stow -t ~ wezterm zsh starship atuin nvim scripts
```

To preview without applying:
```bash
stow -n -v -t ~ wezterm zsh starship atuin nvim scripts
```

### If Existing Configs Conflict

Back up first, then stow:
```bash
mkdir -p ~/dotfiles-backup
[ -f ~/.zshrc ] && mv ~/.zshrc ~/dotfiles-backup/
[ -f ~/.zprofile ] && mv ~/.zprofile ~/dotfiles-backup/
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/dotfiles-backup/
[ -d ~/.config/wezterm ] && mv ~/.config/wezterm ~/dotfiles-backup/
[ -d ~/.config/starship ] && mv ~/.config/starship ~/dotfiles-backup/
[ -d ~/.config/atuin ] && mv ~/.config/atuin ~/dotfiles-backup/
```

## Post-Install

- Restart your terminal or `source ~/.zshrc`
- Open nvim — lazy.nvim will auto-install plugins on first launch
- Mason LSPs will install automatically when you open relevant filetypes
