import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from .icon_resolver import resolve_icon_image

class NotificationCard(Gtk.Box):
    """
    Compact notification card featuring app icon, title, timestamp, body, and dismiss action.
    """
    def __init__(self, noti_data, on_dismiss):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.get_style_context().add_class('noti-card')

        # 1. App Icon
        icon_img = resolve_icon_image(noti_data.get('app_icon', ''), noti_data.get('app_name', ''), size=32)
        icon_img.get_style_context().add_class('noti-icon')
        icon_img.set_valign(Gtk.Align.START)
        self.pack_start(icon_img, False, False, 0)

        # 2. Text Content (Vertical Box)
        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)

        # Top line: Summary / App Name + Timestamp
        top_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        
        name_text = noti_data.get('summary') or noti_data.get('app_name') or 'Notification'
        name_lbl = Gtk.Label(label=name_text)
        name_lbl.set_halign(Gtk.Align.START)
        name_lbl.set_ellipsize(3) # PANGO_ELLIPSIZE_END
        name_lbl.set_max_width_chars(20)
        name_lbl.get_style_context().add_class('noti-app-name')
        top_row.pack_start(name_lbl, False, False, 0)

        time_val = noti_data.get('time')
        time_str = time_val.strftime("%H:%M") if time_val else ""
        time_lbl = Gtk.Label(label=time_str)
        time_lbl.set_halign(Gtk.Align.END)
        time_lbl.get_style_context().add_class('noti-time')
        top_row.pack_end(time_lbl, False, False, 0)

        content_box.pack_start(top_row, False, False, 0)

        # Body preview
        body_text = noti_data.get('body', '')
        if body_text:
            body_lbl = Gtk.Label(label=body_text)
            body_lbl.set_halign(Gtk.Align.START)
            body_lbl.set_line_wrap(True)
            body_lbl.set_max_width_chars(28)
            body_lbl.get_style_context().add_class('noti-body')
            content_box.pack_start(body_lbl, False, False, 0)

        self.pack_start(content_box, True, True, 0)

        # 3. Dismiss Button (✕)
        btn_x = Gtk.Button(label='✕')
        btn_x.get_style_context().add_class('btn-dismiss')
        btn_x.set_valign(Gtk.Align.START)
        btn_x.connect('clicked', lambda b: on_dismiss(noti_data['id']))
        self.pack_end(btn_x, False, False, 0)
