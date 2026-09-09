import datetime
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class CalendarView(Gtk.Box):
    """
    Minimalist calendar widget with sleek date header and month navigation.
    """
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=4)

        # Date Header (Minimalist Apple typography: 'Wednesday, September 9')
        self.date_label = Gtk.Label()
        self.date_label.set_halign(Gtk.Align.START)
        self.date_label.get_style_context().add_class('cal-date-label')
        self.pack_start(self.date_label, False, False, 2)

        # Calendar Widget
        self.cal = Gtk.Calendar()
        self.cal.set_property('show-heading', True)
        self.cal.set_property('show-day-names', True)
        self.cal.set_property('show-week-numbers', False)
        self.cal.connect('day-selected', self._on_day_selected)
        self.pack_start(self.cal, False, False, 0)

        # Hairline Divider
        divider = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
        divider.get_style_context().add_class('hairline-divider')
        self.pack_start(divider, False, False, 2)

        self.reset_to_today()

    def update_header(self, selected_date=None):
        now = datetime.datetime.now()
        if selected_date:
            year, month, day = selected_date
            try:
                display_dt = datetime.date(year, month + 1, day)
            except ValueError:
                display_dt = now.date()
        else:
            display_dt = now.date()

        day_name = display_dt.strftime("%A")
        full_date = display_dt.strftime("%B %d, %Y")
        self.date_label.set_text(f"{day_name}, {full_date}")

    def _on_day_selected(self, widget):
        year, month, day = self.cal.get_date()
        self.update_header((year, month, day))

    def reset_to_today(self):
        now = datetime.datetime.now()
        self.cal.select_month(now.month - 1, now.year)
        self.cal.select_day(now.day)
        self.cal.mark_day(now.day)
        self.update_header()
