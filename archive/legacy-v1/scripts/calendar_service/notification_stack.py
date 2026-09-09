import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from .notification_card import NotificationCard

class NotificationStackGroup(Gtk.Box):
    """
    Apple-style stacked notification group:
    - Collapsed: Displays top card (newest notification) with layered frosted glass shelves
      peeking underneath and an interactive '+N more' indicator pill.
    - Expanded: Displays all notifications from this application in reverse chronological order
      with individual dismiss actions and a 'Show less' collapse trigger.
    """
    def __init__(self, app_name, notifications, on_dismiss, is_expanded=False, on_toggle_expand=None):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.get_style_context().add_class('noti-stack-group')
        self.app_name = app_name
        self.notifications = notifications  # Sorted newest-first
        self.on_dismiss = on_dismiss
        self.is_expanded = is_expanded
        self.on_toggle_expand = on_toggle_expand

        self._build_ui()

    def _build_ui(self):
        count = len(self.notifications)
        if count == 0:
            return

        if count == 1:
            # Standalone notification: render directly as single card
            card = NotificationCard(self.notifications[0], self.on_dismiss)
            self.pack_start(card, False, False, 0)
            return

        if not self.is_expanded:
            self._build_collapsed(count)
        else:
            self._build_expanded()

    def _build_collapsed(self, count):
        # 1. Top Card (Newest notification from this application)
        top_card = NotificationCard(self.notifications[0], self.on_dismiss)
        self.pack_start(top_card, False, False, 0)

        # 2. Layered Stack Shelves (Clickable to expand)
        shelf_event_box = Gtk.EventBox()
        shelf_event_box.set_visible_window(False)
        shelf_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)

        # Shelf 1: Layer directly peeking beneath top card
        shelf_1 = Gtk.Box()
        shelf_1.get_style_context().add_class('noti-stack-shelf-1')
        shelf_box.pack_start(shelf_1, False, False, 0)

        # Shelf 2: Second deeper layer if 3 or more notifications
        if count >= 3:
            shelf_2 = Gtk.Box()
            shelf_2.get_style_context().add_class('noti-stack-shelf-2')
            shelf_box.pack_start(shelf_2, False, False, 0)

        shelf_event_box.add(shelf_box)
        shelf_event_box.connect('button-press-event', lambda w, e: self._trigger_toggle())
        self.pack_start(shelf_event_box, False, False, 0)

        # 3. Stack Indicator Pill (e.g. "󰅀  2 more")
        remaining = count - 1
        pill_btn = Gtk.Button()
        pill_btn.set_relief(Gtk.ReliefStyle.NONE)
        pill_btn.get_style_context().add_class('noti-stack-pill')
        pill_btn.set_halign(Gtk.Align.CENTER)
        pill_btn.set_valign(Gtk.Align.CENTER)

        more_text = f"󰅀  {remaining} more" if remaining > 1 else "󰅀  1 more"
        pill_lbl = Gtk.Label(label=more_text)
        pill_lbl.set_halign(Gtk.Align.CENTER)
        pill_lbl.set_valign(Gtk.Align.CENTER)
        pill_btn.add(pill_lbl)
        pill_btn.connect('clicked', lambda b: self._trigger_toggle())
        self.pack_start(pill_btn, False, False, 0)

    def _build_expanded(self):
        # Container for all cards from this app with subtle spacing
        cards_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        for noti in self.notifications:
            card = NotificationCard(noti, self.on_dismiss)
            cards_box.pack_start(card, False, False, 0)
        self.pack_start(cards_box, False, False, 0)

        # Collapse Button ('󰅃  Show less')
        btn_collapse = Gtk.Button()
        btn_collapse.set_relief(Gtk.ReliefStyle.NONE)
        btn_collapse.get_style_context().add_class('btn-stack-collapse')
        btn_collapse.set_halign(Gtk.Align.CENTER)
        btn_collapse.set_valign(Gtk.Align.CENTER)

        collapse_lbl = Gtk.Label(label="󰅃  Show less")
        collapse_lbl.set_halign(Gtk.Align.CENTER)
        collapse_lbl.set_valign(Gtk.Align.CENTER)
        btn_collapse.add(collapse_lbl)
        btn_collapse.connect('clicked', lambda b: self._trigger_toggle())
        self.pack_start(btn_collapse, False, False, 0)

    def _trigger_toggle(self):
        new_state = not self.is_expanded
        if self.on_toggle_expand:
            self.on_toggle_expand(self.app_name, new_state)
        else:
            self.is_expanded = new_state
            for child in self.get_children():
                self.remove(child)
            self._build_ui()
            self.show_all()
        return True
