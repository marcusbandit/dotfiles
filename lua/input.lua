--------------------------------------------------------------------------------
-- INPUT SETTINGS
--
-- Ported from the `input {}`, `gestures {}` and `cursor {}` blocks of
-- hyprland/general.conf. Everything else in that file (general, decoration,
-- animations, scrolling, master, misc) is ported elsewhere.
--
-- hyprlang's nested blocks map straight onto nested tables in `hl.config`, so
-- `input:touchpad:natural_scroll` is just `input.touchpad.natural_scroll` here.
--------------------------------------------------------------------------------

hl.config({
    input = {
        -- Two layouts, US primary and Danish secondary; `grp:switch` below is
        -- what flips between them.
        kb_layout  = "us,dk",
        kb_variant = "",
        kb_model   = "",
        -- One string, not a list: XKB itself takes a comma-separated option
        -- string, so the comma is part of the value. Caps Lock becomes
        -- Backspace, and the layout group switches on the configured key.
        kb_options = "caps:backspace, grp:switch",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        scroll_factor = 0.8,

        numlock_by_default  = true,
        special_fallthrough = true,

        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },
})

--------------------------------------------------------------------------------
-- Gestures
--
-- general.conf declared an empty `gestures {}` block, so there is nothing to
-- port: no gesture was ever configured. Left as this note rather than an
-- invented `hl.gesture` call, so the absence stays deliberate and visible.
--------------------------------------------------------------------------------
