# === BASE SYSTEM PATH ===
# Always keep these first so core utilities (like clear, ls, grep) work properly
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# === USER BINARIES ===
# Your custom scripts and binaries
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# === PROGRAMMING TOOLS ===
# Binaries from Bun, Cargo (Rust), etc.
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# === APP-SPECIFIC BINARIES ===
# ZenBrowser
export PATH="/usr/lib/zen-browser/zen:$PATH"

# === CONDA / MINIFORGE ===
# Always put this LAST to avoid overriding system binaries like `clear`
export PATH="$PATH:$HOME/miniforge/bin"
export PATH="$PATH:$HOME/miniforge/condabin"

# === AUTO DEDUPLICATE PATH ===
# This removes any duplicate entries from $PATH
export PATH="$(printf "%s" "$PATH" | awk -v RS=: '!a[$1]++ { if(NR==1) printf $1; else printf ":%s", $1 }')"
