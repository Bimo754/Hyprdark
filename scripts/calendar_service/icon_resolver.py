import os
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GdkPixbuf

def resolve_icon_image(app_icon, app_name, size=34):
    """
    Resolves an application icon from icon theme, image file path, or fallback.
    Returns a Gtk.Image sized to the specified dimension.
    """
    theme = Gtk.IconTheme.get_default()

    # 1. Check if app_icon is a direct file path
    if app_icon and os.path.exists(app_icon):
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(app_icon, size, size, True)
            return Gtk.Image.new_from_pixbuf(pixbuf)
        except Exception:
            pass

    # 2. Check if app_icon exists in the current icon theme
    candidate_names = []
    if app_icon:
        candidate_names.append(app_icon)
        candidate_names.append(app_icon.lower())
    if app_name:
        candidate_names.append(app_name.lower().replace(" ", "-"))
        candidate_names.append(app_name.lower())

    for name in candidate_names:
        if theme.has_icon(name):
            try:
                pixbuf = theme.load_icon(name, size, Gtk.IconLookupFlags.FORCE_SIZE)
                if pixbuf:
                    return Gtk.Image.new_from_pixbuf(pixbuf)
            except Exception:
                pass

    # 3. Fallbacks
    for fallback in ['dialog-information', 'preferences-system-notifications', 'application-x-executable']:
        if theme.has_icon(fallback):
            try:
                pixbuf = theme.load_icon(fallback, size, Gtk.IconLookupFlags.FORCE_SIZE)
                if pixbuf:
                    return Gtk.Image.new_from_pixbuf(pixbuf)
            except Exception:
                pass

    # Generic GTK image fallback
    return Gtk.Image.new_from_icon_name('dialog-information', Gtk.IconSize.LARGE_TOOLBAR)
