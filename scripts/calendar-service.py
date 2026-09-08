#!/usr/bin/env python3
"""
Hyprdark - Unified Minimal Frosted Calendar & Notification Center
Pure monochromatic frosted glass design matching the top left island.
"""

import os
import sys
import time
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
/* Window background - Pure Apple Dark frosted glass */
window.dropdown-window {
    background-color: rgba(22, 22, 26, 0.82);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 18px;
    box-shadow: 0 16px 40px rgba(0, 0, 0, 0.55);
}

/* Calendar Section Typography */
.cal-date-label {
    color: #ffffff;
    font-family: 'JetBrainsMono Nerd Font', -apple-system, sans-serif;
    font-size: 13px;
    font-weight: 600;
}

.cal-sub-label {
    color: rgba(255, 255, 255, 0.45);
    font-family: 'JetBrainsMono Nerd Font', -apple-system, sans-serif;
    font-size: 11px;
    font-weight: 500;
}

/* Hairline divider */
.hairline-divider {
    background: rgba(255, 255, 255, 0.08);
    min-height: 1px;
    margin: 8px 0;
}

/* Monochromatic Calendar Widget */
calendar {
    background: transparent;
    color: rgba(255, 255, 255, 0.85);
    border: none;
    font-family: 'JetBrainsMono Nerd Font', monospace;
    font-size: 12px;
}

calendar:selected {
    background-color: rgba(255, 255, 255, 0.18);
    border: 1px solid rgba(255, 255, 255, 0.38);
    border-radius: 999px;
    color: #ffffff;
    font-weight: 700;
}

calendar.header {
    color: #ffffff;
    font-weight: 600;
}

calendar.button {
    color: rgba(255, 255, 255, 0.55);
}

calendar.button:hover {
    color: #ffffff;
}

calendar:indeterminate {
    color: rgba(255, 255, 255, 0.22);
}

/* Notifications Header */
.noti-header-label {
    color: rgba(255, 255, 255, 0.45);
    font-family: 'JetBrainsMono Nerd Font', -apple-system, sans-serif;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.5px;
}

.btn-clear {
    background: rgba(255, 255, 255, 0.08);
    color: rgba(255, 255, 255, 0.70);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 999px;
    padding: 1px 8px;
    font-size: 10px;
    font-weight: 600;
    transition: all 0.15s ease;
}

.btn-clear:hover {
    background: rgba(255, 255, 255, 0.16);
    color: #ffffff;
}

/* Notification Items */
.noti-empty-label {
    color: rgba(255, 255, 255, 0.30);
    font-size: 11.5px;
    padding: 12px 0;
}

.noti-card {
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.07);
    border-radius: 10px;
    padding: 6px 10px;
    margin-bottom: 4px;
    transition: all 0.15s ease;
}

.noti-card:hover {
    background: rgba(255, 255, 255, 0.07);
    border-color: rgba(255, 255, 255, 0.12);
}

.noti-app-name {
    color: #ffffff;
    font-size: 11.5px;
    font-weight: 600;
}

.noti-time {
    color: rgba(255, 255, 255, 0.38);
    font-size: 10px;
}

.noti-body {
    color: rgba(255, 255, 255, 0.65);
    font-size: 11px;
}

.btn-dismiss {
    background: transparent;
    color: rgba(255, 255, 255, 0.30);
    border: none;
    padding: 0 4px;
    font-size: 11px;
}

.btn-dismiss:hover {
    color: #ffffff;
}

/* Minimalist Scrollbar */
scrollbar, scrollbar.vertical {
    background: transparent;
    border: none;
    min-width: 4px;
}
scrollbar slider {
    background: rgba(255, 255, 255, 0.18);
    border-radius: 999px;
    min-width: 4px;
}
scrollbar slider:hover {
    background: rgba(255, 255, 255, 0.35);
}

/* Toast Notification (Popup alert) */
window.toast-window {
    background-color: rgba(22, 22, 26, 0.90);
    border: 1px solid rgba(255, 255, 255, 0.14);
    border-radius: 14px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.50);
}
"""

DBUS_INTROSPECTION_XML = """
<node>
  <interface name='org.freedesktop.Notifications'>
    <method name='Notify'>
      <arg type='s' name='app_name' direction='in'/>
      <arg type='u' name='replaces_id' direction='in'/>
      <arg type='s' name='app_icon' direction='in'/>
      <arg type='s' name='summary' direction='in'/>
      <arg type='s' name='body' direction='in'/>
      <arg type='as' name='actions' direction='in'/>
      <arg type='a{sv}' name='hints' direction='in'/>
      <arg type='i' name='expire_timeout' direction='in'/>
      <arg type='u' name='id' direction='out'/>
    </method>
    <method name='CloseNotification'>
      <arg type='u' name='id' direction='in'/>
    </method>
    <method name='GetCapabilities'>
      <arg type='as' name='capabilities' direction='out'/>
    </method>
    <method name='GetServerInformation'>
      <arg type='s' name='name' direction='out'/>
      <arg type='s' name='vendor' direction='out'/>
      <arg type='s' name='version' direction='out'/>
      <arg type='s' name='spec_version' direction='out'/>
    </method>
    <signal name='NotificationClosed'>
      <arg type='u' name='id'/>
      <arg type='u' name='reason'/>
    </signal>
    <signal name='ActionInvoked'>
      <arg type='u' name='id'/>
      <arg type='s' name='action_key'/>
    </signal>
  </interface>
</node>
"""

class UnifiedCenterService:
    def __init__(self):
        self.notifications = []
        self.next_noti_id = 1
        self.is_visible = False
        
        self.apply_css()
        self.create_dropdown_window()
        self.create_toast_window()
        self.setup_dbus_service()

    def apply_css(self):
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def create_dropdown_window(self):
        self.win = Gtk.Window()
        self.win.set_name("hyprdark-calendar")
        self.win.set_role("hyprdark-calendar")
        self.win.get_style_context().add_class("dropdown-window")

        GtkLayerShell.init_for_window(self.win)
        GtkLayerShell.set_layer(self.win, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_namespace(self.win, "hyprdark-calendar")

        # Centered horizontally, anchored to top
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.BOTTOM, False)
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.LEFT, False)
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.RIGHT, False)
        
        # 54px from top (sits right beneath top bar)
        GtkLayerShell.set_margin(self.win, GtkLayerShell.Edge.TOP, 54)
        GtkLayerShell.set_keyboard_mode(self.win, GtkLayerShell.KeyboardMode.ON_DEMAND)

        # Outer Container
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        box.set_margin_top(12)
        box.set_margin_bottom(12)
        box.set_margin_start(14)
        box.set_margin_end(14)

        # --- CALENDAR HEADER ---
        header_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        self.date_label = Gtk.Label()
        self.date_label.set_halign(Gtk.Align.START)
        self.date_label.get_style_context().add_class('cal-date-label')
        header_box.pack_start(self.date_label, False, False, 0)

        self.sub_label = Gtk.Label()
        self.sub_label.set_halign(Gtk.Align.START)
        self.sub_label.get_style_context().add_class('cal-sub-label')
        header_box.pack_start(self.sub_label, False, False, 0)
        box.pack_start(header_box, False, False, 0)

        # --- CALENDAR WIDGET ---
        self.cal = Gtk.Calendar()
        self.cal.set_property('show-heading', True)
        self.cal.set_property('show-day-names', True)
        self.cal.connect('day-selected', self.on_day_selected)
        box.pack_start(self.cal, False, False, 0)

        # --- HAIRLINE DIVIDER ---
        divider = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
        divider.get_style_context().add_class('hairline-divider')
        box.pack_start(divider, False, False, 0)

        # --- NOTIFICATIONS HEADER ---
        noti_head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.noti_header_label = Gtk.Label(label='NOTIFICATIONS')
        self.noti_header_label.get_style_context().add_class('noti-header-label')
        noti_head.pack_start(self.noti_header_label, False, False, 0)

        self.btn_clear = Gtk.Button(label='Clear')
        self.btn_clear.get_style_context().add_class('btn-clear')
        self.btn_clear.connect('clicked', self.on_clear_clicked)
        noti_head.pack_end(self.btn_clear, False, False, 0)
        box.pack_start(noti_head, False, False, 0)

        # --- NOTIFICATIONS SCROLL CONTAINER ---
        self.scroll = Gtk.ScrolledWindow()
        self.scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.scroll.set_propagate_natural_height(True)
        self.scroll.set_max_content_height(170)
        self.scroll.set_min_content_height(40)

        self.noti_list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        self.noti_list_box.set_margin_top(6)
        self.scroll.add(self.noti_list_box)
        box.pack_start(self.scroll, True, True, 0)

        self.win.add(box)
        self.win.set_size_request(340, -1)
        self.win.connect('key-press-event', self.on_key_press)
        
        self.render_notifications()
        self.update_date_labels()

    def create_toast_window(self):
        self.toast_win = Gtk.Window()
        self.toast_win.get_style_context().add_class("toast-window")
        GtkLayerShell.init_for_window(self.toast_win)
        GtkLayerShell.set_layer(self.toast_win, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_namespace(self.toast_win, "hyprdark-toast")
        GtkLayerShell.set_anchor(self.toast_win, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self.toast_win, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(self.toast_win, GtkLayerShell.Edge.TOP, 54)
        GtkLayerShell.set_margin(self.toast_win, GtkLayerShell.Edge.RIGHT, 14)

        toast_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        toast_box.set_margin_top(8)
        toast_box.set_margin_bottom(8)
        toast_box.set_margin_start(12)
        toast_box.set_margin_end(12)

        self.toast_summary = Gtk.Label()
        self.toast_summary.set_halign(Gtk.Align.START)
        self.toast_summary.get_style_context().add_class('noti-app-name')
        toast_box.pack_start(self.toast_summary, False, False, 0)

        self.toast_body = Gtk.Label()
        self.toast_body.set_halign(Gtk.Align.START)
        self.toast_body.get_style_context().add_class('noti-body')
        toast_box.pack_start(self.toast_body, False, False, 0)

        self.toast_win.add(toast_box)
        self.toast_win.set_size_request(280, -1)
        self.toast_timer = None

    def show_toast(self, summary, body):
        self.toast_summary.set_text(summary)
        self.toast_body.set_text(body)
        self.toast_win.show_all()
        if self.toast_timer:
            GLib.source_remove(self.toast_timer)
        self.toast_timer = GLib.timeout_add_seconds(4, self.hide_toast)

    def hide_toast(self):
        self.toast_win.hide()
        self.toast_timer = None
        return False

    def update_date_labels(self, selected_date=None):
        now = datetime.datetime.now()
        if selected_date:
            year, month, day = selected_date
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

    def toggle(self):
        if self.is_visible:
            self.hide()
        else:
            self.show()

    def show(self):
        self.reset_to_today()
        self.render_notifications()
        self.win.show_all()
        self.is_visible = True

    def hide(self):
        self.win.hide()
        self.is_visible = False

    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()
            return True
        return False

    def on_clear_clicked(self, button):
        self.notifications.clear()
        self.render_notifications()

    def dismiss_notification(self, noti_id):
        self.notifications = [n for n in self.notifications if n['id'] != noti_id]
        self.render_notifications()

    def render_notifications(self):
        for child in self.noti_list_box.get_children():
            self.noti_list_box.remove(child)

        count = len(self.notifications)
        if count > 0:
            self.noti_header_label.set_text(f"NOTIFICATIONS ({count})")
            self.btn_clear.set_sensitive(True)
            self.scroll.set_min_content_height(min(160, 10 + count * 52))
        else:
            self.noti_header_label.set_text("NOTIFICATIONS")
            self.btn_clear.set_sensitive(False)
            self.scroll.set_min_content_height(36)

        if not self.notifications:
            empty = Gtk.Label(label="No Notifications")
            empty.get_style_context().add_class('noti-empty-label')
            self.noti_list_box.pack_start(empty, True, True, 0)
        else:
            for n in reversed(self.notifications[-20:]):
                card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
                card.get_style_context().add_class('noti-card')

                # Top row (App Name, Time, Dismiss Button)
                top_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
                name_lbl = Gtk.Label(label=n['summary'] or n['app_name'])
                name_lbl.set_halign(Gtk.Align.START)
                name_lbl.get_style_context().add_class('noti-app-name')
                top_row.pack_start(name_lbl, False, False, 0)

                # Relative or short time
                t_str = n['time'].strftime("%H:%M")
                time_lbl = Gtk.Label(label=t_str)
                time_lbl.get_style_context().add_class('noti-time')
                top_row.pack_end(time_lbl, False, False, 2)

                btn_x = Gtk.Button(label='✕')
                btn_x.get_style_context().add_class('btn-dismiss')
                btn_x.connect('clicked', lambda b, nid=n['id']: self.dismiss_notification(nid))
                top_row.pack_end(btn_x, False, False, 0)

                card.pack_start(top_row, False, False, 0)

                if n['body']:
                    body_lbl = Gtk.Label(label=n['body'])
                    body_lbl.set_halign(Gtk.Align.START)
                    body_lbl.set_line_wrap(True)
                    body_lbl.set_max_width_chars(32)
                    body_lbl.get_style_context().add_class('noti-body')
                    card.pack_start(body_lbl, False, False, 0)

                self.noti_list_box.pack_start(card, False, False, 0)

        self.noti_list_box.show_all()

    def setup_dbus_service(self):
        try:
            self.node_info = Gio.DBusNodeInfo.new_for_xml(DBUS_INTROSPECTION_XML)
            Gio.bus_own_name(
                Gio.BusType.SESSION,
                'org.freedesktop.Notifications',
                Gio.BusNameOwnerFlags.REPLACE,
                self.on_bus_acquired,
                None,
                None
            )
        except Exception as e:
            print(f"DBus setup error: {e}", file=sys.stderr)

    def on_bus_acquired(self, connection, name):
        try:
            connection.register_object(
                '/org/freedesktop/Notifications',
                self.node_info.interfaces[0],
                self.handle_dbus_call,
                None,
                None
            )
        except Exception as e:
            print(f"Failed to register DBus object: {e}", file=sys.stderr)

    def handle_dbus_call(self, connection, sender, object_path, interface_name, method_name, parameters, invocation, *args):
        if method_name == 'GetCapabilities':
            invocation.return_value(GLib.Variant('(as)', (['body', 'actions'],)))
        elif method_name == 'GetServerInformation':
            invocation.return_value(GLib.Variant('(ssss)', ('hyprdark-notifications', 'Hyprdark', '1.0', '1.2')))
        elif method_name == 'Notify':
            app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout = parameters.unpack()
            noti_id = self.next_noti_id
            self.next_noti_id += 1

            noti_item = {
                'id': noti_id,
                'app_name': app_name or 'System',
                'summary': summary or app_name,
                'body': body or '',
                'time': datetime.datetime.now()
            }
            self.notifications.append(noti_item)
            GLib.idle_add(self.render_notifications)

            # If dropdown is closed, show a subtle toast
            if not self.is_visible:
                GLib.idle_add(lambda: self.show_toast(summary or app_name, body or ''))

            invocation.return_value(GLib.Variant('(u)', (noti_id,)))
        elif method_name == 'CloseNotification':
            nid = parameters.unpack()[0]
            GLib.idle_add(lambda: self.dismiss_notification(nid))
            invocation.return_value(None)

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
        # Already running: trigger toggle via signal
        os.system("pkill -USR1 -f calendar-service.py")
        sys.exit(0)

    service = UnifiedCenterService()

    def on_sigusr1(signum, frame):
        GLib.idle_add(service.toggle)

    def on_sigterm(signum, frame):
        Gtk.main_quit()

    signal.signal(signal.SIGUSR1, on_sigusr1)
    signal.signal(signal.SIGTERM, on_sigterm)
    signal.signal(signal.SIGINT, on_sigterm)

    Gtk.main()

if __name__ == '__main__':
    main()
