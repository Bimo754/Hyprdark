import os
import glob
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GdkPixbuf

# Desktop application icon cache
_APP_DESKTOP_CACHE = {}

def _populate_desktop_cache():
    global _APP_DESKTOP_CACHE
    if _APP_DESKTOP_CACHE:
        return
    for search_dir in ['/usr/share/applications', os.path.expanduser('~/.local/share/applications')]:
        for filepath in glob.glob(os.path.join(search_dir, '*.desktop')):
            base = os.path.basename(filepath)[:-8].lower()
            icon = None
            app_name = None
            try:
                with open(filepath, 'r', errors='ignore') as fp:
                    for line in fp:
                        if line.startswith('Icon=') and not icon:
                            icon = line.strip().split('=', 1)[1]
                        elif line.startswith('Name=') and not app_name:
                            app_name = line.strip().split('=', 1)[1].lower()
            except Exception:
                pass
            if icon:
                _APP_DESKTOP_CACHE[base] = icon
                if app_name:
                    _APP_DESKTOP_CACHE[app_name] = icon
                    first_word = app_name.split()[0]
                    if first_word not in _APP_DESKTOP_CACHE:
                        _APP_DESKTOP_CACHE[first_word] = icon

def resolve_icon_image(app_icon, app_name, size=34):
    """
    Resolves application icon with desktop file resolution, theme lookup, and a clean bell fallback.
    Never uses dialog-information (the lightbulb).
    """
    _populate_desktop_cache()
    theme = Gtk.IconTheme.get_default()

    # 1. Direct file path
    if app_icon and os.path.exists(app_icon):
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(app_icon, size, size, True)
            return Gtk.Image.new_from_pixbuf(pixbuf)
        except Exception:
            pass

    # 2. Build candidate names
    candidates = []
    if app_icon:
        candidates.append(app_icon)
        candidates.append(app_icon.lower())
        mapped = _APP_DESKTOP_CACHE.get(app_icon.lower())
        if mapped:
            candidates.append(mapped)

    if app_name:
        name_clean = app_name.lower().strip()
        candidates.append(name_clean)
        candidates.append(name_clean.replace(" ", "-"))
        mapped = _APP_DESKTOP_CACHE.get(name_clean)
        if mapped:
            candidates.append(mapped)
        first_word = name_clean.split()[0] if name_clean else ""
        mapped_first = _APP_DESKTOP_CACHE.get(first_word)
        if mapped_first:
            candidates.append(mapped_first)

    # Common normalization aliases
    alias_map = {
        'brave-browser': 'brave-desktop',
        'brave': 'brave-desktop',
        'chrome': 'google-chrome',
        'terminal': 'kitty',
        'term': 'kitty',
        'code': 'visual-studio-code',
        'sublime': 'sublime-text',
    }
    for cand in list(candidates):
        if cand in alias_map:
            candidates.append(alias_map[cand])

    # 3. Check theme for candidates
    for name in candidates:
        if name and theme.has_icon(name):
            try:
                pixbuf = theme.load_icon(name, size, Gtk.IconLookupFlags.FORCE_SIZE)
                if pixbuf:
                    return Gtk.Image.new_from_pixbuf(pixbuf)
            except Exception:
                pass

    # 4. Clean Fallbacks - Notification Bell / Emblem (NO LIGHTBULB)
    for fallback in [
        'preferences-system-notifications-symbolic',
        'alarm-symbolic',
        'view-app-grid-symbolic',
        'applications-other'
    ]:
        if theme.has_icon(fallback):
            try:
                pixbuf = theme.load_icon(fallback, size, Gtk.IconLookupFlags.FORCE_SIZE)
                if pixbuf:
                    return Gtk.Image.new_from_pixbuf(pixbuf)
            except Exception:
                pass

    return Gtk.Image.new_from_icon_name('preferences-system-notifications-symbolic', Gtk.IconSize.LARGE_TOOLBAR)
