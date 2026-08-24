# === BASE SYSTEM PATH ===
# Keep the inherited PATH (nix shell, conda, etc. prepend themselves there)
# and append the base dirs as a safety net so core utilities always resolve.
# A hard reset here would wipe nix shell's /nix/store entries on every new shell.
export PATH="${PATH:+$PATH:}/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

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
# ZenBrowser
export PATH="/usr/lib/zen-browser/zen:$PATH"

# === ANDROID SDK ===
# platform-tools first so `adb` is the SDK's build (37.x from the android-tools package
# and 36.x from the SDK fight over the adb server otherwise).
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_AVD_HOME="$HOME/.config/.android/avd"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

# === CONDA / MINIFORGE ===
# Always put this LAST to avoid overriding system binaries like `clear`
#export PATH="$PATH:$HOME/miniforge/bin"
#export PATH="$PATH:$HOME/miniforge/condabin"

# === AUTO DEDUPLICATE PATH ===
# This removes any duplicate entries from $PATH
export PATH="$(printf "%s" "$PATH" | awk -v RS=: '!a[$1]++ { if(NR==1) printf $1; else printf ":%s", $1 }')"
