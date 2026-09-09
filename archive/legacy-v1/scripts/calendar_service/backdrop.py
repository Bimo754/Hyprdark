import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, GtkLayerShell, Gdk

class BackdropLayer:
    """
    Transparent fullscreen layer-shell window placed behind the dropdown card.
    Intercepts any mouse click outside the dropdown and calls dismiss.
    """
    def __init__(self, on_click_outside):
        self.on_click_outside = on_click_outside
        self.win = Gtk.Window()
        self.win.set_app_paintable(True)
        GtkLayerShell.init_for_window(self.win)
        GtkLayerShell.set_layer(self.win, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_namespace(self.win, "hyprdark-backdrop")

        for edge in [GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM,
                     GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT]:
            GtkLayerShell.set_anchor(self.win, edge, True)

        ev_box = Gtk.EventBox()
        ev_box.set_visible_window(False)
        ev_box.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        ev_box.connect('button-press-event', self._on_button_press)
        self.win.add(ev_box)

    def _on_button_press(self, widget, event):
        if callable(self.on_click_outside):
            self.on_click_outside()
        return True

    def show(self):
        self.win.show_all()

    def hide(self):
        self.win.hide()
