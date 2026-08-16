--------------------------------------------------------------------------------
-- ENVIRONMENT VARIABLES
--
-- Ported from hyprland/env.conf. Note on that file: hyprlang's `env` keyword
-- takes `env = NAME,value`. Fifteen lines there used `env = NAME=value`
-- instead, which hyprlang silently ignored, so those variables were never
-- actually set. `hl.env` takes two explicit string arguments, so there is no
-- dead form to hide in here: everything below is live.
--
-- The previously-dead lines are kept commented out at the bottom rather than
-- revived wholesale, so each can be switched on one at a time.
--------------------------------------------------------------------------------

local home = os.getenv("HOME") or "/home/bandit"

--------------------------------------------------------------------------------
-- Live (these worked before and still do)
--------------------------------------------------------------------------------

-- User bins, so keybindings can call scripts by bare name.
-- hyprlang expanded $HOME here; Lua does not, so it is expanded explicitly.
hl.env("PATH", table.concat({
    home .. "/.local/bin",
    home .. "/bin",
    "/usr/local/bin",
    "/usr/bin",
    "/bin",
    "/usr/sbin",
    "/sbin",
}, ":"))

-- Qt platform theme. env.conf set this twice, qt5ct then qt6ct; last write won,
-- so qt6ct is what the session has actually been running. Only the winner is
-- ported.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Cursor
hl.env("XCURSOR_THEME", "Bibata-Modern-DodgerBlue")
hl.env("XCURSOR_SIZE", "24")

-- Terminal for desktop entries with Terminal=true
hl.env("TERMINAL", "kitty")

-- Firefox/Zen Wayland support
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Electron/Chromium Wayland support (fixes Vesktop, VSCode, etc)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

--------------------------------------------------------------------------------
-- GPU note (no variable set on purpose)
--
-- AMD Radeon 840M (Krackan iGPU). No NVIDIA hardware on this box.
-- Deliberately NOT setting LIBVA_DRIVER_NAME; mesa autodetects radeonsi.
-- A stale LIBVA_DRIVER_NAME=nvidia here broke VAAPI entirely and silently
-- forced ffmpeg onto the libx264 CPU fallback (AniBeam transcodes ate 12 cores).
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Never actually applied (the `NAME=value` form hyprlang ignored)
--
-- These are inert today. Uncomment one at a time and relog to see what each
-- one does, rather than switching the whole block on at once.
--------------------------------------------------------------------------------

-- Forces every GTK app to Adwaita dark, overriding the GTK theme setting.
-- hl.env("GTK_THEME", "Adwaita:dark")

-- Drops client-side decorations on Qt apps, so Hyprland's border is the only
-- frame. Worth having, given the greensteel borders do the framing.
-- hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Qt Quick controls follow the GTK style.
-- hl.env("QT_QUICK_CONTROLS_STYLE", "gtk")

-- KDE apps pick up the Breeze Dark colour scheme.
-- hl.env("KDE_COLOR_SCHEME_PATH", "/usr/share/color-schemes/BreezeDark.colors")

-- Stops Java/Swing apps from being reparented into a broken frame under a
-- non-reparenting WM, and turns on font antialiasing + the GTK look and feel.
-- hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
-- hl.env("_JAVA_OPTIONS", "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel")

--------------------------------------------------------------------------------
-- Dropped on purpose
--
-- env.conf also carried these two. Both were inert for the same reason, and
-- both would be actively harmful if made live, so they are not ported:
--
--   env = XDG_RUNTIME_DIR=/tmp/hyprland   -- real value is /run/user/1000.
--       Pointing this at /tmp would move socket and runtime state off the
--       per-user tmpfs, breaking anything that expects the systemd runtime dir.
--
--   env = WAYLAND_DISPLAY=wayland-0       -- real value is wayland-1.
--       Hyprland picks its own socket name; hardcoding a wrong one makes every
--       Wayland client launched from here fail to connect.
--
-- The remaining XDG_* lines in env.conf (CURRENT_DESKTOP, SESSION_DESKTOP,
-- SESSION_TYPE, CONFIG_HOME, DATA_HOME, CACHE_HOME, STATE_HOME) were also
-- inert, and the session already sets all of them to exactly these values, so
-- they are redundant rather than useful.
--------------------------------------------------------------------------------
