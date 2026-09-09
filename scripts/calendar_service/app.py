import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, GtkLayerShell, Gdk
from .config import (
    STYLESHEET_PATH, WINDOW_WIDTH, WINDOW_HEIGHT,
    WINDOW_MARGIN_TOP, MAX_HISTORY_ITEMS
)
from .calendar_view import CalendarView
from .notification_view import NotificationView
from .backdrop import BackdropLayer
from .toast_window import ToastWindow
from .dbus_server import DBusNotificationServer

class DropdownCenterApp:
    """
    Main coordinator uniting the calendar view, notification drawer, backdrop, and toasts.
    """
    def __init__(self):
        self.notifications = []
        self.is_visible = False

        self._load_styles()
        self._build_dropdown_window()
        self.backdrop = BackdropLayer(on_click_outside=self.hide)
        self.toast = ToastWindow()
        self.dbus = DBusNotificationServer(
            on_notify_cb=self._on_dbus_notify,
            on_close_cb=self._on_dbus_close
        )

    def _load_styles(self):
        provider = Gtk.CssProvider()
        try:
            provider.load_from_path(STYLESHEET_PATH)
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )
        except Exception as e:
            print(f"Failed to load CSS: {e}")

    def _build_dropdown_window(self):
        self.win = Gtk.Window()
        self.win.set_name("hyprdark-calendar")
        self.win.set_role("hyprdark-calendar")
        self.win.get_style_context().add_class("dropdown-window")

        GtkLayerShell.init_for_window(self.win)
        GtkLayerShell.set_layer(self.win, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_namespace(self.win, "hyprdark-calendar")
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_margin(self.win, GtkLayerShell.Edge.TOP, WINDOW_MARGIN_TOP)
        GtkLayerShell.set_keyboard_mode(self.win, GtkLayerShell.KeyboardMode.ON_DEMAND)

        container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        container.set_margin_top(16)
        container.set_margin_bottom(16)
        container.set_margin_start(18)
        container.set_margin_end(18)

        self.calendar_view = CalendarView()
        container.pack_start(self.calendar_view, False, False, 0)

        self.noti_view = NotificationView(
            on_dismiss=self.dismiss_notification,
            on_clear_all=self.clear_all_notifications
        )
        container.pack_start(self.noti_view, True, True, 0)

        self.win.add(container)
        self.win.set_size_request(WINDOW_WIDTH, WINDOW_HEIGHT)
        self.win.connect('key-press-event', self._on_key_press)

    def _on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()
            return True
        return False

    def toggle(self):
        if self.is_visible:
            self.hide()
        else:
            self.show()

    def show(self):
        self.calendar_view.reset_to_today()
        self.noti_view.update_list(self.notifications)
        self.backdrop.show()
        self.win.show_all()
        self.is_visible = True

    def hide(self):
        self.win.hide()
        self.backdrop.hide()
        self.is_visible = False

    def dismiss_notification(self, noti_id):
        self.notifications = [n for n in self.notifications if n['id'] != noti_id]
        self.noti_view.update_list(self.notifications)

    def clear_all_notifications(self):
        self.notifications.clear()
        self.noti_view.update_list(self.notifications)

    def _on_dbus_notify(self, noti_dict):
        self.notifications.append(noti_dict)
        if len(self.notifications) > MAX_HISTORY_ITEMS:
            self.notifications.pop(0)

        if self.is_visible:
            self.noti_view.update_list(self.notifications)
        else:
            self.toast.show(
                noti_dict.get('app_name', ''),
                noti_dict.get('summary', ''),
                noti_dict.get('body', ''),
                noti_dict.get('app_icon', '')
            )

    def _on_dbus_close(self, noti_id):
        self.dismiss_notification(noti_id)
