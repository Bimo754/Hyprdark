import os

# Lock and PID files for single-instance enforcement
LOCK_FILE = '/tmp/hyprdark-calendar-service.lock'
PID_FILE = '/tmp/hyprdark-calendar-service.pid'

# Stylesheet path
STYLESHEET_PATH = os.path.join(os.path.dirname(__file__), 'styles.css')

# Dropdown Window Geometry (Dual-Pane Apple Dark Glass Layout)
WINDOW_WIDTH = 580
WINDOW_HEIGHT = 330
WINDOW_MARGIN_TOP = 6

# Notifications Container Sizing (Side-by-side fixed height prevents shifting)
NOTIFICATIONS_SCROLL_HEIGHT = 230
MAX_HISTORY_ITEMS = 30

# Toast Notification Sizing & Timers
TOAST_WIDTH = 360
TOAST_TIMEOUT_SEC = 5
TOAST_MARGIN_TOP = 50
TOAST_MARGIN_RIGHT = 14
