# Environment variables. Grouped by what they configure.

# --- Editor / terminal ---
export EDITOR=nvim
export TERMINAL=kitty
export LESS="-R --mouse --wheel-lines=3"

# --- Prompt (oh-my-posh / conda) ---
export NODE_OPTIONS='--no-deprecation'  # silence node punycode deprecation warnings
export CONDA_PROMPT_MODIFIER=""          # drop the "(base)" prefix from the prompt
export PROMPT_DIRTRIM=3                  # limit directory depth shown in the prompt

# --- fzf (uses fd + ripgrep; integration itself is sourced in ~/.zshrc) ---
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND='fd --type f --hidden --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --border=rounded --preview 'echo Previewing: {}'"

# --- GTK / Qt / portals ---
export GTK_USE_PORTAL=0
export GIO_USE_PORTAL=0
export QT_QPA_PLATFORMTHEME=qt5ct
# GDK scaling left disabled: it over-scales apps launched from the terminal.
# export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5

# --- Cursor theme ---
export XCURSOR_THEME=Bibata-Modern-DodgerBlue
export XCURSOR_SIZE=24

# --- Firefox / Zen on NVIDIA (stability fixes) ---
export MOZ_X11_EGL=0                     # force GLX; EGL has NVIDIA bugs
export MOZ_DISABLE_WAYLAND_PROXY=1       # explicit sync can crash some NVIDIA setups

# --- Misc ---
export _ZO_DOCTOR=0                      # silence zoxide's doctor nag
export QML_XHR_ALLOW_FILE_READ=1         # allow QML/quickshell XHR to read local files
export CVR=45577473
export SATISFACTORY_SCREENSHOTS='/home/bandit/Games/Heroic/Prefixes/default/Satisfactory/drive_c/users/bandit/AppData/Local/FactoryGame/Saved/Screenshots/Windows'
