#!/usr/bin/env python3
# Minimal corner overlays: four solid quarter circles (GTK3 + gtk-layer-shell)
# Arch deps: sudo pacman -S python-gobject python-cairo gtk3 gtk-layer-shell

import os
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GtkLayerShell

RADIUS = 20                   # arc radius
BOX = RADIUS                  # window size per corner (exactly radius)
COLOR = (0.0, 0.0, 0.0, 1.0)  # RGBA
APP_ID = "roundquarter-min"

PI = 3.141592653589793
TWO_PI = 2.0 * PI


class QuarterArea(Gtk.DrawingArea):
    def __init__(self, corner: str):
        super().__init__()
        self.corner = corner
        self.set_size_request(BOX, BOX)
        self.connect("draw", self.on_draw)

    def on_draw(self, _w, cr):
        # Fully transparent background
        cr.set_operator(1)  # CLEAR
        cr.paint()
        cr.set_operator(0)  # OVER

        r = float(RADIUS)
        cr.set_source_rgba(*COLOR)
        cr.new_path()

        if self.corner == "tl":
            cx, cy = r, r
            a0, a1 = PI, 1.5 * PI            # 180° -> 270°
        elif self.corner == "tr":
            cx, cy = BOX - r, r
            a0, a1 = 1.5 * PI, TWO_PI        # 270° -> 360°
        elif self.corner == "br":
            cx, cy = BOX - r, BOX - r
            a0, a1 = 0.0, 0.5 * PI           # 0° -> 90°
        else:  # "bl"
            cx, cy = r, BOX - r
            a0, a1 = 0.5 * PI, PI            # 90° -> 180°

        cr.move_to(cx, cy)
        cr.arc(cx, cy, r, a0, a1)
        cr.close_path()
        cr.fill()
        return False


class CornerQuarter(Gtk.Window):
    def __init__(self, mon: Gdk.Monitor, corner: str):
        Gtk.Window.__init__(self, type=Gtk.WindowType.TOPLEVEL)
        self.set_title(APP_ID)
        self.set_decorated(False)
        self.set_app_paintable(True)
        self.set_resizable(False)
        self.set_accept_focus(False)
        self.set_focus_on_map(False)
        self.set_keep_above(True)

        vis = self.get_screen().get_rgba_visual()
        if vis:
            self.set_visual(vis)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_keyboard_interactivity(self, False)
        GtkLayerShell.auto_exclusive_zone_enable(self)
        GtkLayerShell.set_monitor(self, mon)

        # Anchor to the corner (no inset, no padding)
        if corner == "tl":
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        elif corner == "tr":
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        elif corner == "br":
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        else:  # "bl"
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)

        # Exact-size drawing area
        area = QuarterArea(corner)
        self.add(area)
        self.set_size_request(BOX, BOX)
        self.resize(BOX, BOX)
        self.set_default_size(BOX, BOX)

        # Ensure it never eats input (best-effort)
        self.connect("map-event", self._on_map)
        self.show_all()

    def _on_map(self, *_):
        gdk_win = self.get_window()
        if gdk_win is not None:
            try:
                # Empty input region to pass clicks through
                gdk_win.input_shape_combine_region(None, 0, 0)
            except Exception:
                pass


class App:
    def __init__(self):
        if os.environ.get("WAYLAND_DISPLAY") is None:
            print("Needs Wayland.")
            raise SystemExit(1)

        display = Gdk.Display.get_default()
        n = display.get_n_monitors()
        if n <= 0:
            print("No monitors detected.")
            raise SystemExit(1)

        self.windows = []
        for i in range(n):
            mon = display.get_monitor(i)
            for corner in ("tl", "tr", "br", "bl"):
                self.windows.append(CornerQuarter(mon, corner))

    def run(self):
        Gtk.main()


if __name__ == "__main__":
    App().run()
