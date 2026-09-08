#!/usr/bin/env python3
"""
Hyprdark - Floating Cyber Calendar Layer-Shell Service
Synchronized with SwayNC Control Center over DBus.
"""

import os
import sys
import fcntl
import signal
import datetime
import gi

gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
gi.require_version('Gio', '2.0')
from gi.repository import Gtk, GtkLayerShell, Gio, GLib, Gdk

LOCK_FILE = '/tmp/hyprdark-calendar-service.lock'

CSS = b"""
window {
    background-color: rgba(13, 15, 20, 0.96);
    border: 1px solid rgba(0, 240, 255, 0.35);
    border-radius: 18px;
    box-shadow: 0 16px 48px rgba(0, 0, 0, 0.85);
}

.cal-header {
    padding-bottom: 2px;
}

.cal-date-label {
    color: #00f0ff;
    font-family: 'JetBrainsMono Nerd Font', monospace;
    font-size: 14px;
    font-weight: 700;
    letter-spacing: 0.3px;
}

.cal-sub-label {
    color: #7aa2f7;
    font-family: 'JetBrainsMono Nerd Font', monospace;
    font-size: 11.5px;
    font-weight: 500;
    opacity: 0.90;
}

.cal-divider {
    background: rgba(0, 240, 255, 0.20);
    min-height: 1px;
    margin: 6px 0 8px 0;
}

calendar {
    background: transparent;
    color: #e0e6fc;
    border: none;
    font-family: 'JetBrainsMono Nerd Font', monospace;
    font-size: 12.5px;
}

calendar:selected {
    background-color: #00f0ff;
    color: #08090d;
    border-radius: 6px;
    font-weight: bold;
}

calendar.header {
    color: #7aa2f7;
    font-weight: bold;
    font-size: 13px;
}

calendar.button {
    color: #00f0ff;
}

calendar.highlight {
    color: #bb9af7;
}

calendar:indeterminate {
    color: #565f89;
}
"""

class CalendarService:
    def __init__(self):
        self.apply_css()
        self.create_window()
        self.setup_dbus()

    def apply_css(self):
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def create_window(self):
        self.win = Gtk.Window()
        self.win.set_title("Hyprdark Calendar")
        self.win.set_name("hyprdark-calendar")
        self.win.set_role("hyprdark-calendar")

        GtkLayerShell.init_for_window(self.win)
        GtkLayerShell.set_layer(self.win, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_namespace(self.win, "hyprdark-calendar")
        
        # Center horizontally, anchor to top
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.BOTTOM, False)
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.LEFT, False)
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.RIGHT, False)
        
        # Sits directly underneath the floating top bar (margin-top: 54px)
        GtkLayerShell.set_margin(self.win, GtkLayerShell.Edge.TOP, 54)
        GtkLayerShell.set_keyboard_mode(self.win, GtkLayerShell.KeyboardMode.ON_DEMAND)

        # Outer box
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        box.set_margin_top(12)
        box.set_margin_bottom(12)
        box.set_margin_start(16)
        box.set_margin_end(16)

        # Header Box
        header_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        header_box.get_style_context().add_class('cal-header')

        self.date_label = Gtk.Label()
        self.date_label.set_halign(Gtk.Align.START)
        self.date_label.get_style_context().add_class('cal-date-label')
        header_box.pack_start(self.date_label, False, False, 0)

        self.sub_label = Gtk.Label()
        self.sub_label.set_halign(Gtk.Align.START)
        self.sub_label.get_style_context().add_class('cal-sub-label')
        header_box.pack_start(self.sub_label, False, False, 0)

        box.pack_start(header_box, False, False, 0)

        # Divider line
        divider = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
        divider.get_style_context().add_class('cal-divider')
        box.pack_start(divider, False, False, 0)

        # Interactive Gtk Calendar
        self.cal = Gtk.Calendar()
        self.cal.set_property('show-heading', True)
        self.cal.set_property('show-day-names', True)
        self.cal.connect('day-selected', self.on_day_selected)
        box.pack_start(self.cal, True, True, 0)

        self.win.add(box)
        self.win.set_size_request(380, -1)
        self.win.connect('key-press-event', self.on_key_press)
        
        self.update_date_labels()

    def update_date_labels(self, selected_date=None):
        now = datetime.datetime.now()
        if selected_date:
            year, month, day = selected_date
            # Note: Gtk.Calendar month is 0-indexed
            try:
                display_dt = datetime.date(year, month + 1, day)
            except ValueError:
                display_dt = now.date()
        else:
            display_dt = now.date()

        day_name = display_dt.strftime("%A")
        full_date = display_dt.strftime("%B %d, %Y")
        self.date_label.set_text(f"󰸗  {day_name}, {full_date}")

        week_num = display_dt.isocalendar()[1]
        day_of_year = display_dt.timetuple().tm_yday
        self.sub_label.set_text(f"Week {week_num}  •  Day {day_of_year} of {display_dt.year}")

    def on_day_selected(self, widget):
        year, month, day = self.cal.get_date()
        self.update_date_labels((year, month, day))

    def reset_to_today(self):
        now = datetime.datetime.now()
        self.cal.select_month(now.month - 1, now.year)
        self.cal.select_day(now.day)
        self.cal.mark_day(now.day)
        self.update_date_labels()

    def show(self):
        self.reset_to_today()
        self.win.show_all()

    def hide(self):
        self.win.hide()

    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.close_all()
            return True
        return False

    def close_all(self):
        # Tell SwayNC to close panel
        try:
            Gio.Subprocess.new(['swaync-client', '-cp', '-sw'], Gio.SubprocessFlags.NONE)
        except Exception:
            pass
        self.hide()

    def setup_dbus(self):
        try:
            self.bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
            self.bus.signal_subscribe(
                'org.erikreider.swaync',
                'org.erikreider.swaync.cc',
                None,
                '/org/erikreider/swaync/cc',
                None,
                Gio.DBusSignalFlags.NONE,
                self.on_swaync_signal,
                None
            )
            # Query current visibility
            self.check_initial_visibility()
        except Exception as e:
            print(f"DBus setup error: {e}", file=sys.stderr)

    def check_initial_visibility(self):
        try:
            res = self.bus.call_sync(
                'org.erikreider.swaync',
                '/org/erikreider/swaync/cc',
                'org.erikreider.swaync.cc',
                'GetVisibility',
                None,
                GLib.VariantType('(b)'),
                Gio.DBusCallFlags.NONE,
                500,
                None
            )
            is_visible = res.unpack()[0]
            if is_visible:
                self.show()
            else:
                self.hide()
        except Exception:
            self.hide()

    def on_swaync_signal(self, connection, sender, path, iface, signal_name, params, user_data):
        try:
            data = params.unpack()
            # Subscribe signal: (count: u, dnd: b, visible: b)
            # SubscribeV2 signal: (count: u, dnd: b, visible: b, inhibited: b)
            if signal_name in ('Subscribe', 'SubscribeV2'):
                is_visible = data[2]
                if is_visible:
                    self.show()
                else:
                    self.hide()
        except Exception as e:
            print(f"Error handling signal {signal_name}: {e}", file=sys.stderr)

def acquire_lock():
    lock_fd = open(LOCK_FILE, 'w')
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return lock_fd
    except (IOError, BlockingIOError):
        return None

def main():
    lock = acquire_lock()
    if not lock:
        # Already running
        print("hyprdark-calendar-service is already running.", file=sys.stderr)
        sys.exit(0)

    service = CalendarService()

    def on_sigterm(signum, frame):
        Gtk.main_quit()

    signal.signal(signal.SIGTERM, on_sigterm)
    signal.signal(signal.SIGINT, on_sigterm)

    Gtk.main()

if __name__ == '__main__':
    main()
