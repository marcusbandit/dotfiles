export EDITOR=nvim
export TERMINAL=kitty
export LESS="-R --mouse --wheel-lines=3"

export GTK_USE_PORTAL=0
export GIO_USE_PORTAL=0

export CVR=45577473

# GDK Gnome things
# Disabled: Causes apps launched from terminal to be over-scaled
# export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5

# KDE QT
export QT_QPA_PLATFORMTHEME=qt5ct # Or qt5ct. I will change if needed

export _ZO_DOCTOR=0

# Firefox/Zen NVIDIA GPU stability fixes
# Forces GLX instead of EGL (EGL has bugs with NVIDIA)
export MOZ_X11_EGL=0
# Explicit sync can cause crashes on some NVIDIA setups
export MOZ_DISABLE_WAYLAND_PROXY=1

export QML_XHR_ALLOW_FILE_READ=1
