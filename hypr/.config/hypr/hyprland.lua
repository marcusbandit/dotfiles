--------------------------------------------------------------------------------
-- Hyprland configuration
--
-- Hyprland 0.55 deprecated hyprlang in favour of Lua, and 0.56.1 started
-- printing a deprecation notice for .conf configs. Upstream said hyprlang would
-- survive "1 to 2 releases starting from 0.55", so this is ported ahead of the
-- removal rather than after it.
--
-- Hyprland loads hyprland.lua if it exists and falls back to hyprland.conf
-- otherwise, and it decides once at startup. The old .conf tree is still on
-- disk untouched, so the rollback is:
--
--     mv ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.off
--
-- followed by a relog. A reload is not enough; the choice is made at startup.
--
-- Check a change without logging out:
--
--     Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
--
-- That catches syntax errors, unknown config keys, unknown rule fields, bad
-- dispatchers and out-of-range values. It does NOT catch suppress_event typos
-- or non-namespace match keys in a layer rule, both of which fail silently.
--
-- Modules live in lua/ and are loaded in dependency order below. package.path
-- has this directory prepended by Hyprland, which is why require("lua.x")
-- resolves to lua/x.lua.
--------------------------------------------------------------------------------

-- Environment first, so everything spawned later inherits it.
require("lua.env")

-- Appearance. look and rules both pull the greensteel palette from lua/theme.lua.
require("lua.look")

-- Input devices and cursor.
require("lua.input")

-- Outputs, and which workspace lives on which output.
require("lua.monitors")

-- Window and layer rules.
require("lua.rules")

-- Keybinds and submaps.
require("lua.binds")

-- Autostart last, so it runs against a fully applied config.
require("lua.autostart")
