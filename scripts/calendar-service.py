#!/usr/bin/env python3
"""
Hyprdark - Calendar & Notification Center Service
Modular entrypoint launching the unified calendar and notification daemon.
"""

import os
import sys
import fcntl
import signal

# Ensure package directory is importable even when invoked via symlink
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib

from calendar_service.config import LOCK_FILE
from calendar_service.app import DropdownCenterApp

def acquire_lock():
    lock_fd = open(LOCK_FILE, 'w')
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return lock_fd
    except (IOError, BlockingIOError):
        return None

def main():
    signal.signal(signal.SIGHUP, signal.SIG_IGN)
    lock = acquire_lock()
    if not lock:
        os.system("pkill -USR1 -f calendar-service.py")
        sys.exit(0)

    app = DropdownCenterApp()

    def on_usr1():
        app.toggle()
        return True

    def on_quit():
        Gtk.main_quit()
        return False

    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR1, on_usr1)
    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, on_quit)
    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, on_quit)

    Gtk.main()

if __name__ == '__main__':
    main()
