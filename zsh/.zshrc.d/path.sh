# === BASE SYSTEM PATH ===
# Always keep these first so core utilities (like clear, ls, grep) work properly
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# === NPM GLOBAL BINARIES ===
# Global npm packages
export PATH="$HOME/.npm-global/bin:$PATH"

# === USER BINARIES ===
# Your custom scripts and binaries
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# === PROGRAMMING TOOLS ===
# Binaries from Bun, Cargo (Rust), etc.
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# === APP-SPECIFIC BINARIES ===
export PATH="/usr/lib/zen-browser/zen:$PATH"   # Zen Browser
export PATH="$HOME/.spicetify:$PATH"           # spicetify

# === CONDA / MINIFORGE ===
# Deliberately NOT on PATH here: conda is opt-in and set up in ~/.zshrc (CONDA_MANUAL).

# === AUTO DEDUPLICATE PATH ===
# This removes any duplicate entries from $PATH
export PATH="$(printf "%s" "$PATH" | awk -v RS=: '!a[$1]++ { if(NR==1) printf $1; else printf ":%s", $1 }')"
