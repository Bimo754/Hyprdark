import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from .icon_resolver import resolve_icon_image

class NotificationCard(Gtk.Box):
    """
    Fortified notification card featuring a centered squircle icon badge,
    aligned typography hierarchy, and a vertically centered dismiss action.
    """
    def __init__(self, noti_data, on_dismiss):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.get_style_context().add_class('noti-card')

        # 1. Fortified App Icon Badge (Mathematically Centered Squircle)
        icon_wrapper = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        icon_wrapper.set_valign(Gtk.Align.CENTER)
        icon_wrapper.set_halign(Gtk.Align.CENTER)
        icon_wrapper.set_size_request(38, 38)
        icon_wrapper.get_style_context().add_class('noti-icon-badge')

        icon_img = resolve_icon_image(noti_data.get('app_icon', ''), noti_data.get('app_name', ''), size=24)
        icon_img.set_valign(Gtk.Align.CENTER)
        icon_img.set_halign(Gtk.Align.CENTER)
        icon_wrapper.pack_start(icon_img, True, True, 0)
        self.pack_start(icon_wrapper, False, False, 0)

        # 2. Text Content (Vertical Box, Vertically Centered)
        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        content_box.set_valign(Gtk.Align.CENTER)

        # Top line: Summary / App Name + Timestamp
        top_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        top_row.set_valign(Gtk.Align.CENTER)

        name_text = noti_data.get('summary') or noti_data.get('app_name') or 'Notification'
        name_lbl = Gtk.Label(label=name_text)
        name_lbl.set_halign(Gtk.Align.START)
        name_lbl.set_ellipsize(3) # PANGO_ELLIPSIZE_END
        name_lbl.set_max_width_chars(20)
        name_lbl.get_style_context().add_class('noti-app-name')
        top_row.pack_start(name_lbl, False, False, 0)

        time_val = noti_data.get('time')
        if hasattr(time_val, 'strftime'):
            time_str = time_val.strftime("%H:%M")
        elif isinstance(time_val, str):
            time_str = time_val
        else:
            time_str = noti_data.get('timestamp', '')

        if time_str:
            time_lbl = Gtk.Label(label=time_str)
            time_lbl.set_halign(Gtk.Align.END)
            time_lbl.get_style_context().add_class('noti-time')
            top_row.pack_end(time_lbl, False, False, 0)

        content_box.pack_start(top_row, False, False, 0)

        # Body preview (if available)
        body_text = noti_data.get('body', '').strip()
        if body_text:
            body_lbl = Gtk.Label(label=body_text)
            body_lbl.set_halign(Gtk.Align.START)
            body_lbl.set_line_wrap(True)
            body_lbl.set_max_width_chars(28)
            body_lbl.get_style_context().add_class('noti-body')
            content_box.pack_start(body_lbl, False, False, 0)

        self.pack_start(content_box, True, True, 0)

        # 3. Dismiss Button (✕, Vertically Centered)
        btn_x = Gtk.Button(label='✕')
        btn_x.set_relief(Gtk.ReliefStyle.NONE)
        btn_x.get_style_context().add_class('btn-dismiss')
        btn_x.set_valign(Gtk.Align.CENTER)
        btn_x.set_halign(Gtk.Align.CENTER)
        btn_x.connect('clicked', lambda b: on_dismiss(noti_data['id']))
        self.pack_end(btn_x, False, False, 0)
