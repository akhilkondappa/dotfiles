#!/bin/bash

set -e

echo "=== Dotfiles Setup ==="

# Install xCode cli tools
if [[ "$(uname)" == "Darwin" ]]; then
    if xcode-select -p &>/dev/null; then
        echo "✓ Xcode CLI tools already installed"
    else
        echo "Installing Xcode CLI tools..."
        xcode-select --install
    fi
fi

# Homebrew
if command -v brew &>/dev/null; then
    echo "✓ Homebrew already installed"
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew analytics off

# oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✓ oh-my-zsh already installed"
else
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# oh-my-zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-system-clipboard" ] && \
    git clone https://github.com/kutsan/zsh-system-clipboard.git "$ZSH_CUSTOM/plugins/zsh-system-clipboard"

## Taps
brew tap satococoa/tap

## Formulae
echo "Installing brew packages..."
brew install coreutils stow fzf bat fd zoxide lua ripgrep eza \
    git lazygit neovim starship tree-sitter tree \
    node nvm atuin satococoa/tap/wtp

# Casks
echo "Installing casks..."
brew install --cask wezterm@nightly
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font

# GNU Stow — symlink dotfiles
echo "Stowing dotfiles..."
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

# Ensure ~/.config exists
mkdir -p "$HOME/.config"

stow -t ~ wezterm zsh starship atuin nvim scripts

echo "=== Setup complete! ==="
echo "Restart your terminal or run: source ~/.zshrc"
