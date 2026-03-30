#!/bin/bash
# Dotfiles installer
# Creates symlinks from dotfiles repo to their expected locations.
# Safe: backs up existing files before overwriting.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$DOTFILES_DIR/.backup/$(date +%Y%m%d_%H%M%S)"

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$1"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[1;32m[OK]\033[0m    %s\n" "$1"; }
err()   { printf "\033[1;31m[ERROR]\033[0m %s\n" "$1"; }

# Create a symlink, backing up existing file if needed
link_file() {
    local src="$1"
    local dst="$2"

    if [ ! -f "$src" ] && [ ! -d "$src" ]; then
        warn "Source not found: $src (skipping)"
        return
    fi

    local dst_dir
    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"

    if [ -L "$dst" ]; then
        local current_target
        current_target="$(readlink "$dst")"
        if [ "$current_target" = "$src" ]; then
            ok "Already linked: $dst"
            return
        fi
        warn "Removing old symlink: $dst -> $current_target"
        rm "$dst"
    elif [ -f "$dst" ] || [ -d "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        local rel_path="${dst#$HOME/}"
        local backup_path="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_path")"
        mv "$dst" "$backup_path"
        warn "Backed up: $dst -> $backup_path"
    fi

    ln -s "$src" "$dst"
    ok "Linked: $dst -> $src"
}

# -------------------------------------------------------
# Oh My Zsh
# -------------------------------------------------------
install_omz() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok "Oh My Zsh already installed"
    else
        info "Installing Oh My Zsh..."
        RUNZSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # Powerlevel10k
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ -d "$p10k_dir" ]; then
        ok "Powerlevel10k already installed"
    else
        info "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi

    # zsh-autosuggestions
    local as_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    if [ -d "$as_dir" ]; then
        ok "zsh-autosuggestions already installed"
    else
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$as_dir"
    fi

    # zsh-syntax-highlighting
    local sh_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    if [ -d "$sh_dir" ]; then
        ok "zsh-syntax-highlighting already installed"
    else
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$sh_dir"
    fi
}

# -------------------------------------------------------
# Zellij
# -------------------------------------------------------
install_zellij() {
    if command -v zellij &>/dev/null; then
        ok "Zellij already installed"
    else
        info "Installing Zellij..."
        curl -sSfL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz -C /tmp
        install /tmp/zellij "$HOME/.local/bin/zellij"
        ok "Zellij installed to ~/.local/bin/zellij"
    fi
}

# -------------------------------------------------------
# Main
# -------------------------------------------------------
main() {
    info "Dotfiles installer starting..."
    info "Dotfiles dir: $DOTFILES_DIR"
    echo

    # --- Dependencies ---
    info "=== Installing dependencies ==="
    install_omz
    install_zellij
    echo

    # --- Zsh ---
    info "=== Linking Zsh configs ==="
    link_file "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
    link_file "$DOTFILES_DIR/zsh/.zshenv"   "$HOME/.zshenv"
    link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    echo

    # --- Zellij ---
    info "=== Linking Zellij config ==="
    link_file "$DOTFILES_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
    echo

    # --- Claude Code ---
    info "=== Linking Claude Code configs ==="
    link_file "$DOTFILES_DIR/claude/CLAUDE.md"       "$HOME/.claude/CLAUDE.md"
    link_file "$DOTFILES_DIR/claude/settings.json"   "$HOME/.claude/settings.json"
    link_file "$DOTFILES_DIR/claude/hooks/pre-commit-codex-review.sh" \
              "$HOME/.claude/hooks/pre-commit-codex-review.sh"
    link_file "$DOTFILES_DIR/claude/skills/codex-review/SKILL.md" \
              "$HOME/.claude/skills/codex-review/SKILL.md"
    link_file "$DOTFILES_DIR/claude/skills/doc-format/SKILL.md" \
              "$HOME/.claude/skills/doc-format/SKILL.md"
    echo

    # --- Codex ---
    info "=== Linking Codex configs ==="
    link_file "$DOTFILES_DIR/codex/config.toml"        "$HOME/.codex/config.toml"
    link_file "$DOTFILES_DIR/codex/rules/default.rules" "$HOME/.codex/rules/default.rules"
    echo

    # --- Done ---
    info "=== Installation complete ==="
    echo
    info "Next steps:"
    info "  1. Restart your shell or run: source ~/.zshrc"
    info "  2. Add trusted projects to ~/.codex/config.toml if needed"
    info "  3. Run 'p10k configure' if prompt looks off on a new machine"
}

main "$@"
