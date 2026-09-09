import os

# Lock file for single-instance enforcement
LOCK_FILE = '/tmp/hyprdark-calendar-service.lock'

# Stylesheet path
STYLESHEET_PATH = os.path.join(os.path.dirname(__file__), 'styles.css')

# Dropdown Window Geometry
WINDOW_WIDTH = 390
WINDOW_HEIGHT = 460
WINDOW_MARGIN_TOP = 44

# Notifications Container Sizing (Stable height prevents layout shifting)
NOTIFICATIONS_SCROLL_HEIGHT = 180
MAX_HISTORY_ITEMS = 30

# Toast Notification Sizing & Timers
TOAST_WIDTH = 360
TOAST_TIMEOUT_SEC = 5
TOAST_MARGIN_TOP = 50
TOAST_MARGIN_RIGHT = 14
