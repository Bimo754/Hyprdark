import os
import glob
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GdkPixbuf

# Desktop application icon cache
_APP_DESKTOP_CACHE = {}

# Modern Vector / Symbolic overrides for network, system, and peripheral notifications
# Replaces 1990s legacy/skeuomorphic bitmap icons (nm-device-wireless, etc.) with clean Apple-style SVG symbols
SYMBOLIC_OVERRIDE_MAP = {
    # Wireless / Wi-Fi / BSSID connection icons
    'network-wireless': 'network-wireless-signal-excellent-symbolic',
    'nm-device-wireless': 'network-wireless-signal-excellent-symbolic',
    'network-wireless-connected': 'network-wireless-signal-excellent-symbolic',
    'network-wireless-signal-excellent': 'network-wireless-signal-excellent-symbolic',
    'network-wireless-signal-good': 'network-wireless-signal-good-symbolic',
    'network-wireless-signal-ok': 'network-wireless-signal-ok-symbolic',
    'network-wireless-signal-weak': 'network-wireless-signal-weak-symbolic',
    'network-wireless-signal-none': 'network-wireless-signal-none-symbolic',
    'network-wireless-acquiring': 'network-wireless-acquiring-symbolic',
    'network-wireless-offline': 'network-wireless-offline-symbolic',
    'network-wireless-disconnected': 'network-wireless-offline-symbolic',
    'nm-no-connection': 'network-offline-symbolic',
    'network-offline': 'network-offline-symbolic',
    'network-error': 'network-offline-symbolic',
    # Wired Network
    'nm-device-wired': 'network-wired-symbolic',
    'network-wired': 'network-wired-symbolic',
    # Bluetooth
    'bluetooth-active': 'bluetooth-active-symbolic',
    'bluetooth-paired': 'bluetooth-active-symbolic',
    'bluetooth-disabled': 'bluetooth-disabled-symbolic',
    'bluetooth-disconnected': 'bluetooth-disabled-symbolic',
    # Audio
    'audio-volume-high': 'audio-volume-high-symbolic',
    'audio-volume-medium': 'audio-volume-medium-symbolic',
    'audio-volume-low': 'audio-volume-low-symbolic',
    'audio-volume-muted': 'audio-volume-muted-symbolic',
}

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

def resolve_icon_image(app_icon, app_name, size=26):
    """
    Resolves application icon with desktop file resolution, symbolic overrides, and pixmap lookups.
    Returns Gtk.Image if a valid real icon is found, or None if no icon exists.
    Per design rules: NEVER returns a fallback bell emoji or placeholder.
    """
    _populate_desktop_cache()
    theme = Gtk.IconTheme.get_default()

    # 1. Direct file path
    if app_icon and os.path.isabs(app_icon) and os.path.exists(app_icon):
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(app_icon, size, size, True)
            return Gtk.Image.new_from_pixbuf(pixbuf)
        except Exception:
            pass

    # 2. Check Symbolic Overrides (Fixes weird BSSID / NetworkManager retro bitmaps)
    if app_icon:
        icon_clean = app_icon.lower().strip()
        if icon_clean in SYMBOLIC_OVERRIDE_MAP:
            sym_name = SYMBOLIC_OVERRIDE_MAP[icon_clean]
            if theme.has_icon(sym_name):
                try:
                    pixbuf = theme.load_icon(sym_name, size, Gtk.IconLookupFlags.FORCE_SIZE)
                    if pixbuf:
                        return Gtk.Image.new_from_pixbuf(pixbuf)
                except Exception:
                    pass

    # 3. Build candidate names
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
        candidates.append(name_clean.replace(" ", ""))
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
        'vscode': 'visual-studio-code',
        'sublime': 'sublime-text',
        'networkmanager applet': 'network-wireless-signal-excellent-symbolic',
        'networkmanager': 'network-wireless-signal-excellent-symbolic',
        'wifi': 'network-wireless-signal-excellent-symbolic',
    }
    for cand in list(candidates):
        if cand in alias_map:
            candidates.append(alias_map[cand])

    # 4. Check standard GTK Icon Theme
    for name in candidates:
        if name and theme.has_icon(name):
            try:
                pixbuf = theme.load_icon(name, size, Gtk.IconLookupFlags.FORCE_SIZE)
                if pixbuf:
                    return Gtk.Image.new_from_pixbuf(pixbuf)
            except Exception:
                pass

    # 5. Check direct pixmaps directory (/usr/share/pixmaps/)
    for name in candidates:
        for ext in ['.png', '.svg']:
            pixmap_path = os.path.join('/usr/share/pixmaps', name + ext)
            if os.path.exists(pixmap_path):
                try:
                    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(pixmap_path, size, size, True)
                    return Gtk.Image.new_from_pixbuf(pixbuf)
                except Exception:
                    pass

    # No valid application icon found -> return None (no fallback bell or placeholder)
    return None
