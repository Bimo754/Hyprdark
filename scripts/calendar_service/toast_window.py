import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, GtkLayerShell, GLib
from .config import TOAST_WIDTH, TOAST_TIMEOUT_SEC, TOAST_MARGIN_TOP, TOAST_MARGIN_RIGHT
from .icon_resolver import resolve_icon_image

class ToastWindow:
    """
    Spacious toast alert displaying incoming notifications with app logo, title, and body.
    """
    def __init__(self):
        self.win = Gtk.Window()
        self.win.get_style_context().add_class("toast-window")
        GtkLayerShell.init_for_window(self.win)
        GtkLayerShell.set_layer(self.win, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_namespace(self.win, "hyprdark-toast")
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self.win, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(self.win, GtkLayerShell.Edge.TOP, TOAST_MARGIN_TOP)
        GtkLayerShell.set_margin(self.win, GtkLayerShell.Edge.RIGHT, TOAST_MARGIN_RIGHT)

        # Outer Container
        main_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        main_box.set_margin_top(10)
        main_box.set_margin_bottom(10)
        main_box.set_margin_start(12)
        main_box.set_margin_end(12)

        # Icon placeholder
        self.icon_box = Gtk.Box()
        main_box.pack_start(self.icon_box, False, False, 0)

        # Content Box
        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        self.summary_lbl = Gtk.Label()
        self.summary_lbl.set_halign(Gtk.Align.START)
        self.summary_lbl.get_style_context().add_class('noti-app-name')
        content_box.pack_start(self.summary_lbl, False, False, 0)

        self.body_lbl = Gtk.Label()
        self.body_lbl.set_halign(Gtk.Align.START)
        self.body_lbl.set_line_wrap(True)
        self.body_lbl.set_max_width_chars(32)
        self.body_lbl.get_style_context().add_class('noti-body')
        content_box.pack_start(self.body_lbl, False, False, 0)

        main_box.pack_start(content_box, True, True, 0)

        self.win.add(main_box)
        self.win.set_size_request(TOAST_WIDTH, -1)
        self.timer_id = None

    def show(self, app_name, summary, body, app_icon):
        for child in self.icon_box.get_children():
            self.icon_box.remove(child)

        icon_img = resolve_icon_image(app_icon, app_name, size=36)
        self.icon_box.pack_start(icon_img, False, False, 0)

        self.summary_lbl.set_text(summary or app_name or 'Notification')
        self.body_lbl.set_text(body or '')
        self.win.show_all()

        if self.timer_id:
            GLib.source_remove(self.timer_id)
        self.timer_id = GLib.timeout_add_seconds(TOAST_TIMEOUT_SEC, self.hide)

    def hide(self):
        self.win.hide()
        self.timer_id = None
        return False
