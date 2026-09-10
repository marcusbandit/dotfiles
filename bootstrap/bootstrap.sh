#!/bin/bash
# =============================================================================
# Rice Bootstrap Script
# Syncs dotfiles, packages, scripts, and fonts to a new/existing machine
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config
DOTFILES_REPO="https://github.com/marcusbandit/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.rice-backup-$(date +%Y%m%d_%H%M%S)"

# Stow packages to install (order matters for dependencies)
STOW_PACKAGES=(zsh nvim tmux ghostty hypr waybar qs sddm wallpapers scripts)

# =============================================================================
# Helper Functions
# =============================================================================

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "\n${CYAN}=== $1 ===${NC}\n"; }

confirm() {
    read -p "$1 [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# =============================================================================
# Pre-flight Checks
# =============================================================================

preflight() {
    log_section "Pre-flight Checks"

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run this as root!"
        exit 1
    fi

    # Check for required tools
    local missing=()
    for cmd in git stow pacman; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        exit 1
    fi

    # Check for yay (AUR helper)
    if ! command -v yay &>/dev/null; then
        log_warn "yay not found. Installing..."
        install_yay
    fi

    log_success "Pre-flight checks passed"
}

install_yay() {
    log_info "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    cd "$tmp/yay"
    makepkg -si --noconfirm
    cd -
    rm -rf "$tmp"
    log_success "yay installed"
}

# =============================================================================
# Dotfiles
# =============================================================================

setup_dotfiles() {
    log_section "Dotfiles Setup"

    if [[ -d "$DOTFILES_DIR" ]]; then
        log_info "Dotfiles directory exists, pulling latest..."
        git -C "$DOTFILES_DIR" pull --rebase || log_warn "Pull failed, continuing with existing"
    else
        log_info "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi

    log_success "Dotfiles ready at $DOTFILES_DIR"
}

# =============================================================================
# Stow Dotfiles
# =============================================================================

stow_packages() {
    log_section "Stowing Configurations"

    cd "$DOTFILES_DIR"

    for pkg in "${STOW_PACKAGES[@]}"; do
        if [[ -d "$pkg" ]]; then
            log_info "Stowing $pkg..."

            # Try stow, if conflicts exist, back them up
            if ! stow -n "$pkg" 2>/dev/null; then
                log_warn "Conflicts detected for $pkg, backing up..."
                backup_conflicts "$pkg"
            fi

            stow --restow "$pkg" 2>/dev/null || stow "$pkg"
            log_success "Stowed $pkg"
        else
            log_warn "Package $pkg not found, skipping"
        fi
    done

    cd -
}

backup_conflicts() {
    local pkg="$1"
    mkdir -p "$BACKUP_DIR"

    # Find what stow would link and back up existing files
    cd "$DOTFILES_DIR/$pkg"
    find . -type f | while read -r file; do
        local target="$HOME/${file#./}"
        if [[ -e "$target" && ! -L "$target" ]]; then
            local backup_path="$BACKUP_DIR/${file#./}"
            mkdir -p "$(dirname "$backup_path")"
            mv "$target" "$backup_path"
            log_info "Backed up: $target"
        elif [[ -L "$target" ]]; then
            rm "$target"  # Remove old symlink
        fi
    done
    cd -
}

# =============================================================================
# Packages
# =============================================================================

install_packages() {
    log_section "Installing Packages"

    local native_list="$DOTFILES_DIR/bootstrap/packages-native.txt"
    local aur_list="$DOTFILES_DIR/bootstrap/packages-aur.txt"

    if [[ -f "$native_list" ]]; then
        log_info "Installing native packages ($(wc -l < "$native_list") packages)..."
        # Filter out already installed packages
        local to_install=$(comm -23 <(sort "$native_list") <(pacman -Qeq | sort) | tr '\n' ' ')
        if [[ -n "$to_install" ]]; then
            sudo pacman -S --needed --noconfirm $to_install || log_warn "Some native packages failed"
        else
            log_info "All native packages already installed"
        fi
        log_success "Native packages done"
    fi

    if [[ -f "$aur_list" ]]; then
        log_info "Installing AUR packages ($(wc -l < "$aur_list") packages)..."
        local to_install=$(comm -23 <(sort "$aur_list") <(pacman -Qmq | sort 2>/dev/null || echo "") | tr '\n' ' ')
        if [[ -n "$to_install" ]]; then
            yay -S --needed --noconfirm $to_install || log_warn "Some AUR packages failed"
        else
            log_info "All AUR packages already installed"
        fi
        log_success "AUR packages done"
    fi
}

# =============================================================================
# Fonts
# =============================================================================

setup_fonts() {
    log_section "Fonts Setup"

    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    # Install nerd fonts via pacman if available
    local font_packages=(ttf-jetbrains-mono-nerd ttf-firacode-nerd)
    log_info "Installing font packages..."
    sudo pacman -S --needed --noconfirm "${font_packages[@]}" 2>/dev/null || log_warn "Some font packages not found"

    # Rebuild font cache
    log_info "Rebuilding font cache..."
    fc-cache -fv &>/dev/null

    log_success "Fonts setup complete"
}

# =============================================================================
# Extra Scripts (rsync from source machine)
# =============================================================================

sync_scripts_remote() {
    log_section "Sync Scripts from Remote"

    echo "To sync scripts from your main machine, run this ON YOUR MAIN MACHINE:"
    echo ""
    echo -e "${CYAN}  rsync -avz --progress ~/.local/bin/ <laptop-user>@<laptop-ip>:~/.local/bin/${NC}"
    echo ""
    echo "Or if you have SSH access to this machine from main:"
    echo ""
    echo -e "${CYAN}  rsync -avz --progress <main-user>@<main-ip>:~/.local/bin/ ~/.local/bin/${NC}"
    echo ""
}

# =============================================================================
# Post-install
# =============================================================================

post_install() {
    log_section "Post-install Setup"

    # Set zsh as default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "Setting zsh as default shell..."
        chsh -s $(which zsh) || log_warn "Failed to change shell, do it manually: chsh -s \$(which zsh)"
    fi

    # Install oh-my-zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Reminder for manual steps
    echo ""
    log_section "Manual Steps Remaining"
    echo "1. Log out and back in (or reboot) for shell changes"
    echo "2. Run: rsync scripts from main machine (see above)"
    echo "3. Run: stow any additional packages you need"
    echo "4. SDDM theme may need: sudo cp -r ~/dotfiles/sddm/... (check structure)"
    echo ""

    if [[ -d "$BACKUP_DIR" ]]; then
        log_warn "Backed up configs are at: $BACKUP_DIR"
    fi
}

# =============================================================================
# Main Menu
# =============================================================================

show_menu() {
    echo ""
    echo -e "${CYAN}Rice Bootstrap Script${NC}"
    echo "====================="
    echo "1) Full install (recommended for fresh systems)"
    echo "2) Dotfiles only (clone + stow)"
    echo "3) Packages only"
    echo "4) Stow only (dotfiles already cloned)"
    echo "5) Show rsync command for scripts"
    echo "6) Export current packages (run on main machine)"
    echo "q) Quit"
    echo ""
    read -p "Choose option: " choice

    case $choice in
        1)
            preflight
            setup_dotfiles
            install_packages
            stow_packages
            setup_fonts
            sync_scripts_remote
            post_install
            ;;
        2)
            preflight
            setup_dotfiles
            stow_packages
            post_install
            ;;
        3)
            preflight
            setup_dotfiles  # Need package lists from repo
            install_packages
            ;;
        4)
            preflight
            stow_packages
            ;;
        5)
            sync_scripts_remote
            ;;
        6)
            log_info "Exporting packages..."
            pacman -Qeq | sort > "$DOTFILES_DIR/bootstrap/packages-native.txt"
            pacman -Qmq | sort > "$DOTFILES_DIR/bootstrap/packages-aur.txt"
            log_success "Exported to $DOTFILES_DIR/bootstrap/"
            log_info "Don't forget to commit and push!"
            ;;
        q|Q)
            exit 0
            ;;
        *)
            log_error "Invalid option"
            show_menu
            ;;
    esac
}

# =============================================================================
# Entry Point
# =============================================================================

# If run with arguments, execute specific function
if [[ $# -gt 0 ]]; then
    case $1 in
        --full) preflight; setup_dotfiles; install_packages; stow_packages; setup_fonts; post_install ;;
        --dotfiles) preflight; setup_dotfiles; stow_packages ;;
        --packages) preflight; setup_dotfiles; install_packages ;;
        --stow) preflight; stow_packages ;;
        --export)
            pacman -Qeq | sort > "$DOTFILES_DIR/bootstrap/packages-native.txt"
            pacman -Qmq | sort > "$DOTFILES_DIR/bootstrap/packages-aur.txt"
            echo "Exported to $DOTFILES_DIR/bootstrap/"
            ;;
        *) echo "Usage: $0 [--full|--dotfiles|--packages|--stow|--export]" ;;
    esac
else
    show_menu
fi
