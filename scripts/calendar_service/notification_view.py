import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from .config import NOTIFICATIONS_SCROLL_HEIGHT
from .notification_card import NotificationCard

class NotificationView(Gtk.Box):
    """
    Fixed-height notifications section with header, clear button, and scroll container.
    Maintains constant height so removing a notification never moves the window.
    """
    def __init__(self, on_dismiss, on_clear_all):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        self.on_dismiss = on_dismiss
        self.on_clear_all = on_clear_all

        # Header Row: Title & Clear Button
        header_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.header_label = Gtk.Label(label='NOTIFICATIONS')
        self.header_label.get_style_context().add_class('noti-header-label')
        header_row.pack_start(self.header_label, False, False, 0)

        self.btn_clear = Gtk.Button(label='Clear All')
        self.btn_clear.set_relief(Gtk.ReliefStyle.NONE)
        self.btn_clear.get_style_context().add_class('btn-clear')
        self.btn_clear.connect('clicked', lambda b: self.on_clear_all())
        header_row.pack_end(self.btn_clear, False, False, 0)
        self.pack_start(header_row, False, False, 2)

        # Scrolled Window (Fixed dimensions prevent layout jumping)
        self.scroll = Gtk.ScrolledWindow()
        self.scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.scroll.set_propagate_natural_height(False)
        self.scroll.set_min_content_height(NOTIFICATIONS_SCROLL_HEIGHT)
        self.scroll.set_max_content_height(NOTIFICATIONS_SCROLL_HEIGHT)

        self.list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        self.list_box.set_margin_top(4)
        self.scroll.add(self.list_box)
        self.pack_start(self.scroll, True, True, 0)

    def update_list(self, notifications):
        for child in self.list_box.get_children():
            self.list_box.remove(child)

        count = len(notifications)
        if count > 0:
            self.header_label.set_text(f"NOTIFICATIONS ({count})")
            self.btn_clear.set_sensitive(True)
            for n in reversed(notifications):
                card = NotificationCard(n, self.on_dismiss)
                self.list_box.pack_start(card, False, False, 0)
        else:
            self.header_label.set_text("NOTIFICATIONS")
            self.btn_clear.set_sensitive(False)
            empty_lbl = Gtk.Label(label="No Notifications")
            empty_lbl.get_style_context().add_class('noti-empty-label')
            self.list_box.pack_start(empty_lbl, True, True, 0)

        self.list_box.show_all()
