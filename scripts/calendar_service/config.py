import os

# Lock and PID files for single-instance enforcement
LOCK_FILE = '/tmp/hyprdark-calendar-service.lock'
PID_FILE = '/tmp/hyprdark-calendar-service.pid'

# Stylesheet path
STYLESHEET_PATH = os.path.join(os.path.dirname(__file__), 'styles.css')

# Dropdown Window Geometry (Mathematically balanced proportions)
WINDOW_WIDTH = 420
WINDOW_HEIGHT = 500
WINDOW_MARGIN_TOP = 46

# Notifications Container Sizing (Stable height prevents layout shifting)
NOTIFICATIONS_SCROLL_HEIGHT = 200
MAX_HISTORY_ITEMS = 30

# Toast Notification Sizing & Timers
TOAST_WIDTH = 360
TOAST_TIMEOUT_SEC = 5
TOAST_MARGIN_TOP = 50
TOAST_MARGIN_RIGHT = 14
