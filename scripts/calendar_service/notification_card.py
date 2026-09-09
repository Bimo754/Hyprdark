import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from .icon_resolver import resolve_icon_image

class NotificationCard(Gtk.Box):
    """
    Apple Dark Mode notification card featuring:
    - Pure transparent icon positioning (no background box; omitted entirely if app has no icon)
    - Mathematically aligned typography hierarchy with xalign=0.0
    - Cohesive header row (Program Name · Time) preventing detached timestamps
    - Subtle vertically-centered dismiss action
    """
    def __init__(self, noti_data, on_dismiss):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.get_style_context().add_class('noti-card')

        # 1. App Icon (Transparent background like VPN telemetry; omitted if app has no icon)
        icon_img = resolve_icon_image(noti_data.get('app_icon', ''), noti_data.get('app_name', ''), size=26)
        if icon_img is not None:
            icon_wrapper = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            icon_wrapper.set_valign(Gtk.Align.CENTER)
            icon_wrapper.set_halign(Gtk.Align.CENTER)
            icon_wrapper.set_size_request(30, 30)
            icon_wrapper.get_style_context().add_class('noti-icon-badge')

            icon_img.set_valign(Gtk.Align.CENTER)
            icon_img.set_halign(Gtk.Align.CENTER)
            icon_wrapper.pack_start(icon_img, True, True, 0)
            self.pack_start(icon_wrapper, False, False, 0)

        # 2. Text Content (Vertical Box, Vertically Centered)
        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        content_box.set_valign(Gtk.Align.CENTER)

        # Timestamp resolution
        time_val = noti_data.get('time')
        if hasattr(time_val, 'strftime'):
            time_str = time_val.strftime("%H:%M")
        elif isinstance(time_val, str):
            time_str = time_val
        else:
            time_str = noti_data.get('timestamp', '')

        # Resolve Header Program Name & Summary
        app_name = noti_data.get('app_name', '').strip()
        summary = noti_data.get('summary', '').strip()

        # If app_name is empty or generic, use summary as header
        if not app_name or app_name.lower() in ['notify-send', 'notification']:
            header_name = summary or 'Notification'
            sub_title = ''
        else:
            header_name = app_name
            sub_title = summary if summary.lower() != app_name.lower() else ''

        # Row 1: Header (Program Name · Time)
        header_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        header_row.set_valign(Gtk.Align.CENTER)

        name_lbl = Gtk.Label(label=header_name)
        name_lbl.set_xalign(0.0)
        name_lbl.set_halign(Gtk.Align.START)
        name_lbl.set_ellipsize(3) # PANGO_ELLIPSIZE_END
        name_lbl.set_max_width_chars(18)
        name_lbl.get_style_context().add_class('noti-app-name')
        header_row.pack_start(name_lbl, False, False, 0)

        if time_str:
            dot_lbl = Gtk.Label(label='·')
            dot_lbl.get_style_context().add_class('noti-dot')
            header_row.pack_start(dot_lbl, False, False, 0)

            time_lbl = Gtk.Label(label=time_str)
            time_lbl.set_xalign(0.0)
            time_lbl.get_style_context().add_class('noti-time')
            header_row.pack_start(time_lbl, False, False, 0)

        content_box.pack_start(header_row, False, False, 0)

        # Row 2: Sub-Title / Summary (if distinct from program name)
        if sub_title:
            title_lbl = Gtk.Label(label=sub_title)
            title_lbl.set_xalign(0.0)
            title_lbl.set_halign(Gtk.Align.START)
            title_lbl.set_ellipsize(3)
            title_lbl.set_max_width_chars(24)
            title_lbl.get_style_context().add_class('noti-title')
            content_box.pack_start(title_lbl, False, False, 0)

        # Row 3: Description / Body Text (Mathematically aligned at x=0.0)
        body_text = noti_data.get('body', '').strip()
        if body_text:
            body_lbl = Gtk.Label(label=body_text)
            body_lbl.set_xalign(0.0)
            body_lbl.set_halign(Gtk.Align.START)
            body_lbl.set_line_wrap(True)
            body_lbl.set_max_width_chars(28)
            body_lbl.get_style_context().add_class('noti-body')
            content_box.pack_start(body_lbl, False, False, 0)

        self.pack_start(content_box, True, True, 0)

        # 3. Dismiss Action (✕, Vertically Centered)
        btn_x = Gtk.Button(label='✕')
        btn_x.set_relief(Gtk.ReliefStyle.NONE)
        btn_x.get_style_context().add_class('btn-dismiss')
        btn_x.set_valign(Gtk.Align.CENTER)
        btn_x.set_halign(Gtk.Align.CENTER)
        btn_x.connect('clicked', lambda b: on_dismiss(noti_data['id']))
        self.pack_end(btn_x, False, False, 0)
