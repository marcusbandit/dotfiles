-- Keybindings, ported from hyprland/keybinds.conf
--
-- Bind variant mapping used throughout:
--   binde  -> { repeating = true }
--   bindl  -> { locked = true }
--   bindel -> { locked = true, repeating = true }
--   bindm  -> { mouse = true }
--   bindd  -> { description = "..." }

-- Program variables, from hyprland.conf. Only the ones the binds actually use.
local terminal    = "kitty"
local browser     = "zen-browser"
local filemanager = "yazi"

-- Shared direction data. Drives three families of binds: layout focus, window
-- movement, and the keyboard-driven cursor. One table, four rows, no per-key
-- special cases.
local directions = {
    { key = "LEFT",  msg = "l", name = "left",  dx = -1, dy =  0 },
    { key = "RIGHT", msg = "r", name = "right", dx =  1, dy =  0 },
    { key = "UP",    msg = "u", name = "up",    dx =  0, dy = -1 },
    { key = "DOWN",  msg = "d", name = "down",  dx =  0, dy =  1 },
}

local workspace_count = 10 -- workspaces 1..N, bound to the digit row
local cursor_step     = 20 -- pixels per ydotool mousemove step


-- #! Viewport

-- Focus.
-- layoutmsg, not the focus dispatcher: this config runs the `scrolling` layout,
-- where `layoutmsg focus` moves through the column strip rather than the
-- geometric neighbour that `hl.dsp.focus` would pick.
for _, d in ipairs(directions) do
    hl.bind("SUPER + " .. d.key, hl.dsp.layout("focus " .. d.msg), { repeating = true })
end

-- Workspaces.
-- Digit row: 1..9 map to their own digit, workspace 10 sits on the "0" key,
-- hence `i % workspace_count`.
for i = 1, workspace_count do
    hl.bind("SUPER + " .. tostring(i % workspace_count), hl.dsp.focus({ workspace = i }))
end

hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special("communication"))
hl.bind("SUPER + tab",   hl.dsp.workspace.toggle_special("music"))


-- #! Window

-- State
hl.bind("SUPER + A",         hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- Fullscreen
hl.bind("SUPER + SHIFT + A", hl.dsp.window.fullscreen({ mode = "maximized" }))  -- Maximize
hl.bind("SUPER + D",         hl.dsp.window.pseudo())                            -- Pseudo-tile
hl.bind("SUPER + G",         hl.dsp.window.pin())                               -- Makes a floating type "Global" - persists across all workspaces.
hl.bind("SUPER + Q",         hl.dsp.window.close())                             -- Kill the hovered window
hl.bind("SUPER + S",         hl.dsp.window.float({ action = "toggle" }))        -- Toggle floating state
hl.bind("SUPER + F",         hl.dsp.layout("fit active"))                       -- Rescales the current window to fit the entire screen
hl.bind("SUPER + SHIFT + F", hl.dsp.layout("fit visible"))                      -- Rescales all the visible windows on the screen to fit the screen

-- Layout
for _, d in ipairs(directions) do
    hl.bind("SUPER + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.name }), { repeating = true })
end

-- layoutmsg again, for the same scrolling-layout reason as the focus binds above.
hl.bind("SUPER + SHIFT + RETURN",           hl.dsp.layout("promote"))
hl.bind("SUPER + SHIFT + CONTROL + RIGHT",  hl.dsp.layout("swapcol r"))
hl.bind("SUPER + SHIFT + CONTROL + LEFT",   hl.dsp.layout("swapcol l"))

-- Move to workspace (same digit-row math as the focus binds).
for i = 1, workspace_count do
    hl.bind("SUPER + SHIFT + " .. tostring(i % workspace_count), hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special:communication" }))
hl.bind("SUPER + SHIFT + tab",   hl.dsp.window.move({ workspace = "special:music" }))

-- Move / Resize with mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + X",         hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + SHIFT + X", hl.dsp.window.resize(), { mouse = true })


-- #! Apps

hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("banditshell launcher toggle"))

-- The calculator panel, out of the sidebar's flank. A toggle like every other
-- surface, and SUPER+K was free. The launcher answers a sum typed straight into
-- it (SUPER+SPACE, "2+3*4", Enter puts 14 on the clipboard), so this is for the
-- sums worked through a step at a time rather than for every one of them.
hl.bind("SUPER + K", hl.dsp.exec_cmd("banditshell calculator toggle"))

-- The original carried an inline window rule: `exec, [pseudeo; size 3440 1440;] $browser`.
-- It is deliberately NOT ported. Two independent reasons: "pseudeo" was a typo for
-- "pseudo", so hyprlang never recognised the rule and it has been inert all along,
-- and the 3440x1440 sizing was written for banditbox's ultrawide, not for this
-- laptop. So the browser just launches, which is what has actually been happening.
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))

hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private-window"))
hl.bind("SUPER + E",         hl.dsp.exec_cmd(terminal .. " -e " .. filemanager))
hl.bind("SUPER + RETURN",    hl.dsp.exec_cmd(terminal))

-- Copilot key: remapped to a plain Super modifier by keyd (/etc/keyd/default.conf).
-- The hardware chord Super+Shift+F23 never reaches Hyprland anymore, so no bind here.


-- #! Utils

-- Network
hl.bind("SUPER + I", hl.dsp.exec_cmd("~/bin/wifi-menu")) -- Wi-Fi menu (connect to any network)

-- Shell
hl.bind("SUPER + P", hl.dsp.exec_cmd("banditshell session toggle")) -- Toggle Power Menu
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))      -- Lock the session

-- THE WAY OUT, and it is the least clever bind in this file on purpose.
--
-- Several banditshell surfaces take the keyboard EXCLUSIVELY while they are
-- up (the launcher, the power panel, the hotkey sheet, a pinned menu) and put
-- a full-screen region into the input mask so a click anywhere off them puts
-- them away. Each is right on its own. Together they mean that a surface left
-- open by something that died mid-sequence takes the whole desktop with it:
-- no window holds focus, so SUPER + LEFT/RIGHT have nothing to act on, and
-- every click lands on the shell instead of on what is under it. The desktop
-- looks frozen while being perfectly healthy.
--
-- You cannot type your way out, because the terminal does not have the
-- keyboard either. A compositor bind still fires, so this is the only rescue
-- that can work.
hl.bind("SUPER + SHIFT + ESCAPE", hl.dsp.exec_cmd("banditshell close")) -- Shut every shell surface (rescue)

-- banditshell has no sidebar drawer, dashboard or hideable bar yet, so these
-- three have nothing to talk to now that caelestia is no longer the shell. Left
-- here rather than deleted, as the list of what still has to be built.
-- hl.bind("SUPER + N",         hl.dsp.exec_cmd("caelestia shell drawers toggle sidebar"))   -- Toggle Notification panel
-- hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("caelestia shell drawers toggle dashboard")) -- Toggle Dashboard
-- hl.bind("SUPER + Z",         hl.dsp.exec_cmd("caelestia shell bar togglePersistent"))     -- Toggle Bar

-- Clipboard
hl.bind("SUPER + J",      hl.dsp.exec_cmd("~/.local/bin/ollama-clipboard"))                                -- Send Clipboard to Ollama
hl.bind("SUPER + V",      hl.dsp.exec_cmd("banditshell clipboard toggle"))                                 -- Clipboard history
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("env TYPE_CLIPBOARD_DEBUG=1 /home/bandit/.local/bin/type-clipboard")) -- Type clipboard

-- Copy text from screenshot. Long brackets: the command carries its own double quotes.
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd(
    [[grim -g "$(slurp $SLURP_ARGS)" "/tmp/ocr_image.png" && tesseract "/tmp/ocr_image.png" stdout -l eng | wl-copy && rm "/tmp/ocr_image.png"]]
))

hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("banditshell picker freezeclip")) -- Take screenshot

-- Tools
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a --format=hex"))                     -- Color Picker

-- Voice dictation: tap to start, tap again to stop and type.
--
-- One bind, not the press/release pair this used to be: with a toggle the key
-- is not what holds the mic open, so there is nothing to bind on release.
-- Because the keyboard no longer tells you the mic is live, the daemon puts up
-- a notification that stays on screen for the whole recording, and caps a
-- forgotten session so it cannot record for hours.
--
-- This key used to launch `xhisper`, which has not existed on this box for a
-- while, so the bind and its submap were both dead. Same key, working tool.
hl.bind("SUPER + R", hl.dsp.exec_cmd("voice toggle")) -- Dictate: tap on, tap off

-- Retype the last transcription, wherever focus is now. No mic, no Whisper: it
-- replays the text the daemon already has, so it is instant and identical every
-- time. For the miss - focus was on the wrong window, the field ate it, an undo
-- went one step too far - where saying a long paragraph again is the expensive
-- part, not the typing. Refused while a recording is live, so it can never
-- interleave with the dictation it would be replaying.
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("voice retype")) -- Retype last dictation

-- The wallpaper, which banditshell draws itself now: its own surface on the
-- background layer, so swww has nothing left to put a picture on and is not
-- running. The old bind is kept below rather than deleted, because the day swww
-- comes back it is the line you want.
--
-- TEMPORARY HOME. This key is only borrowed until the toggle finds a better
-- one; `banditshell wallpaper next` is the closest thing to what W used to do
-- if you would rather have that here.
hl.bind("SUPER + W",         hl.dsp.exec_cmd("banditshell wallpaper toggle"))                   -- Wallpaper on/off
-- hl.bind("SUPER + W",      hl.dsp.exec_cmd("~/.local/bin/swww-random"))                       -- Cycle backgrounds

-- Task manager. Long brackets again: three quoted arguments, one of them with && inside.
hl.bind("CTRL + SHIFT + grave", hl.dsp.exec_cmd(
    [[~/.config/hypr/hyprland/scripts/launch_first_available.sh "gnome-system-monitor" "plasma-systemmonitor --page-name Processes" "command -v btop && kitty -1 fish -c btop"]]
))

-- Cursor (mouse via keyboard). Deltas come from the direction table times the step.
for _, d in ipairs(directions) do
    hl.bind(
        "SUPER + CTRL + " .. d.key,
        hl.dsp.exec_cmd(string.format("ydotool mousemove -- %d %d", d.dx * cursor_step, d.dy * cursor_step)),
        { repeating = true }
    )
end

hl.bind("SUPER + CTRL + SPACE",         hl.dsp.exec_cmd("ydotool click 0xC0"))
hl.bind("SUPER + CTRL + ALT_L + SPACE", hl.dsp.exec_cmd("ydotool click 0xC1"))

-- Quickshell
hl.bind("SUPER + Slash", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Toggle cheatsheet" }) -- Toggle cheatsheet
-- banditshell's hotkey sheet, through the CLI like every other verb it has.
-- `?` is SHIFT + slash on the US half of kb_layout "us,dk", so the bind names
-- the unshifted key. The description is what the sheet prints beside the chord.
hl.bind("SUPER + SHIFT + Slash", hl.dsp.exec_cmd("banditshell hotkeys toggle"), { description = "Toggle the hotkey sheet" }) -- Hotkey sheet
-- hl.bind("mouse:275", hl.dsp.exec_cmd("~/.local/bin/toggle-quickshell"))  -- was `bindn`, no modifier

-- Emergency
hl.bind("SUPER + F4", hl.dsp.exit()) -- Exit Hyprland immediately (emergency escape)


-- #! Laptop

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Media
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


-- #! Submaps

-- (The xhisper dictation submap lived here. It is gone along with the bind that
--  entered it: dictation is now hold-to-talk under #! Tools, which needs no
--  submap and therefore has no stuck state to escape from.)
