import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from .config import NOTIFICATIONS_SCROLL_HEIGHT
from .notification_card import NotificationCard

class NotificationView(Gtk.Box):
    """
    Fixed-height notifications section with header, pill count badge, red-hover clear button,
    and scroll container maintaining constant geometry.
    """
    def __init__(self, on_dismiss, on_clear_all):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        self.on_dismiss = on_dismiss
        self.on_clear_all = on_clear_all

        # Header Row: Title + Count Badge + Clear Button
        header_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        header_row.set_valign(Gtk.Align.CENTER)

        title_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        title_box.set_valign(Gtk.Align.CENTER)

        self.header_label = Gtk.Label(label='NOTIFICATIONS')
        self.header_label.get_style_context().add_class('noti-header-label')
        title_box.pack_start(self.header_label, False, False, 0)

        self.count_badge = Gtk.Label()
        self.count_badge.get_style_context().add_class('noti-count-badge')
        title_box.pack_start(self.count_badge, False, False, 0)

        header_row.pack_start(title_box, False, False, 0)

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

        self.list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.list_box.set_margin_top(4)
        self.scroll.add(self.list_box)
        self.pack_start(self.scroll, True, True, 0)

    def update_list(self, notifications):
        for child in self.list_box.get_children():
            self.list_box.remove(child)

        count = len(notifications)
        if count > 0:
            self.count_badge.set_text(str(count))
            self.count_badge.show()
            self.btn_clear.set_sensitive(True)
            for n in reversed(notifications):
                card = NotificationCard(n, self.on_dismiss)
                self.list_box.pack_start(card, False, False, 0)
        else:
            self.count_badge.hide()
            self.btn_clear.set_sensitive(False)

            empty_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
            empty_box.set_valign(Gtk.Align.CENTER)
            empty_box.set_halign(Gtk.Align.CENTER)
            empty_box.set_margin_top(45)

            empty_icon = Gtk.Label(label="󰂚")
            empty_icon.get_style_context().add_class('noti-empty-icon')
            empty_box.pack_start(empty_icon, False, False, 0)

            empty_lbl = Gtk.Label(label="No Notifications")
            empty_lbl.get_style_context().add_class('noti-empty-label')
            empty_box.pack_start(empty_lbl, False, False, 0)

            self.list_box.pack_start(empty_box, True, True, 0)

        self.list_box.show_all()
        if count == 0:
            self.count_badge.hide()
