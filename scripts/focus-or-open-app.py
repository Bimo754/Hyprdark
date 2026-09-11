#!/usr/bin/env python3
import sys
import json
import subprocess
import os

def focus_or_open(app_name, desktop_entry=""):
    if not app_name:
        return

    # 1. Check open clients in Hyprland
    try:
        res = subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True, check=True)
        clients = json.loads(res.stdout)
    except Exception:
        clients = []

    clean_app = app_name.strip().lower()
    clean_entry = desktop_entry.strip().lower().replace(".desktop", "") if desktop_entry else ""

    aliases = {
        "spotify": ["spotify"],
        "discord": ["discord", "vesktop", "webcord"],
        "firefox": ["firefox", "navigator"],
        "chrome": ["google-chrome", "chromium", "brave"],
        "brave": ["brave-browser", "brave"],
        "sublime": ["subl", "sublime_text"],
        "code": ["code", "vscode"],
        "terminal": ["kitty", "alacritty", "foot"],
    }

    search_terms = {clean_app}
    if clean_entry:
        search_terms.add(clean_entry)
    for k, v in aliases.items():
        if k in clean_app or any(x in clean_app for x in v):
            search_terms.update(v)

    target_address = None
    for c in clients:
        c_cls = (c.get("class") or "").lower()
        c_icls = (c.get("initialClass") or "").lower()
        c_title = (c.get("title") or "").lower()

        for term in search_terms:
            if term and (term in c_cls or term in c_icls or term in c_title):
                target_address = c.get("address")
                break
        if target_address:
            break

    if target_address:
        cmd = f"hl.dsp.focus({{ window = 'address:{target_address}' }})"
        subprocess.run(["hyprctl", "dispatch", cmd], check=False)
        return

    # 2. Not open: launch it
    launch_targets = []
    if desktop_entry:
        launch_targets.append(desktop_entry.replace(".desktop", ""))
    if clean_app:
        launch_targets.append(clean_app)

    for target in launch_targets:
        try:
            res = subprocess.run(["gtk-launch", target], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if res.returncode == 0:
                return
        except Exception:
            pass

    try:
        subprocess.Popen([clean_app], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    except Exception:
        pass

if __name__ == "__main__":
    app = sys.argv[1] if len(sys.argv) > 1 else ""
    entry = sys.argv[2] if len(sys.argv) > 2 else ""
    focus_or_open(app, entry)
