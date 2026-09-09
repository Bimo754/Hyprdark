import calendar
import datetime
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class CalendarView(Gtk.Box):
    """
    Custom Apple Dark Mode calendar widget.
    Renders a mathematically aligned 7-column grid with smooth chevron navigation,
    frosted glass 'today' lens, and clean weekday headers without Gtk.Calendar clutter.
    """
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.get_style_context().add_class('cal-container')
        self.set_size_request(248, -1)

        now = datetime.datetime.now()
        self.current_year = now.year
        self.current_month = now.month
        self.view_year = now.year
        self.view_month = now.month
        self.selected_day = now.day

        # 1. Month / Year Navigation Header
        nav_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        nav_row.get_style_context().add_class('cal-nav-row')

        self.btn_prev = Gtk.Button(label='‹')
        self.btn_prev.set_relief(Gtk.ReliefStyle.NONE)
        self.btn_prev.get_style_context().add_class('cal-nav-btn')
        self.btn_prev.connect('clicked', lambda b: self._change_month(-1))
        nav_row.pack_start(self.btn_prev, False, False, 0)

        self.month_title = Gtk.Button()
        self.month_title.set_relief(Gtk.ReliefStyle.NONE)
        self.month_title.get_style_context().add_class('cal-month-title-btn')
        self.month_title.connect('clicked', lambda b: self.reset_to_today())
        nav_row.pack_start(self.month_title, True, True, 0)

        self.btn_next = Gtk.Button(label='›')
        self.btn_next.set_relief(Gtk.ReliefStyle.NONE)
        self.btn_next.get_style_context().add_class('cal-nav-btn')
        self.btn_next.connect('clicked', lambda b: self._change_month(1))
        nav_row.pack_start(self.btn_next, False, False, 0)

        self.pack_start(nav_row, False, False, 0)

        # 2. Weekday Column Headers
        weekday_grid = Gtk.Grid()
        weekday_grid.set_column_homogeneous(True)
        weekday_grid.get_style_context().add_class('cal-weekday-grid')
        for col_idx, day_name in enumerate(['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']):
            lbl = Gtk.Label(label=day_name)
            lbl.get_style_context().add_class('cal-weekday-lbl')
            weekday_grid.attach(lbl, col_idx, 0, 1, 1)
        self.pack_start(weekday_grid, False, False, 2)

        # 3. Calendar Day Grid (7 columns, homogeneous spacing)
        self.day_grid = Gtk.Grid()
        self.day_grid.set_column_homogeneous(True)
        self.day_grid.set_row_spacing(3)
        self.day_grid.set_column_spacing(2)
        self.day_grid.get_style_context().add_class('cal-day-grid')
        self.pack_start(self.day_grid, False, False, 2)

        # 4. Footer Glance
        self.glance_lbl = Gtk.Label()
        self.glance_lbl.get_style_context().add_class('cal-glance-lbl')
        self.glance_lbl.set_halign(Gtk.Align.CENTER)
        self.pack_end(self.glance_lbl, False, False, 2)

        self.render_calendar()

    def _change_month(self, delta):
        self.view_month += delta
        if self.view_month < 1:
            self.view_month = 12
            self.view_year -= 1
        elif self.view_month > 12:
            self.view_month = 1
            self.view_year += 1
        self.render_calendar()

    def reset_to_today(self):
        now = datetime.datetime.now()
        self.current_year = now.year
        self.current_month = now.month
        self.view_year = now.year
        self.view_month = now.month
        self.selected_day = now.day
        self.render_calendar()

    def render_calendar(self):
        for child in self.day_grid.get_children():
            self.day_grid.remove(child)

        month_name = datetime.date(self.view_year, self.view_month, 1).strftime("%B %Y")
        self.month_title.set_label(month_name)

        now = datetime.datetime.now()
        is_current_month = (self.view_year == now.year and self.view_month == now.month)

        cal_gen = calendar.Calendar(firstweekday=6)
        weeks = cal_gen.monthdayscalendar(self.view_year, self.view_month)

        for row_idx, week in enumerate(weeks):
            for col_idx, day in enumerate(week):
                if day == 0:
                    empty_box = Gtk.Box()
                    empty_box.set_size_request(28, 25)
                    self.day_grid.attach(empty_box, col_idx, row_idx, 1, 1)
                else:
                    btn = Gtk.Button(label=str(day))
                    btn.set_relief(Gtk.ReliefStyle.NONE)
                    btn.set_size_request(28, 25)
                    btn.get_style_context().add_class('cal-day-btn')

                    if is_current_month and day == now.day:
                        btn.get_style_context().add_class('cal-day-today')
                    elif is_current_month and day == self.selected_day:
                        btn.get_style_context().add_class('cal-day-selected')

                    btn.connect('clicked', self._on_day_clicked, day)
                    self.day_grid.attach(btn, col_idx, row_idx, 1, 1)

        # Update Glance Label
        try:
            sel_date = datetime.date(self.view_year, self.view_month, self.selected_day if is_current_month else 1)
            self.glance_lbl.set_text(sel_date.strftime("%A, %B %d, %Y"))
        except ValueError:
            self.glance_lbl.set_text(now.strftime("%A, %B %d, %Y"))

        self.day_grid.show_all()

    def _on_day_clicked(self, widget, day):
        self.selected_day = day
        self.render_calendar()
