import sys
import datetime
import gi
gi.require_version('Gio', '2.0')
from gi.repository import Gio, GLib

DBUS_INTROSPECTION_XML = """
<node>
  <interface name='org.freedesktop.Notifications'>
    <method name='Notify'>
      <arg type='s' name='app_name' direction='in'/>
      <arg type='u' name='replaces_id' direction='in'/>
      <arg type='s' name='app_icon' direction='in'/>
      <arg type='s' name='summary' direction='in'/>
      <arg type='s' name='body' direction='in'/>
      <arg type='as' name='actions' direction='in'/>
      <arg type='a{sv}' name='hints' direction='in'/>
      <arg type='i' name='expire_timeout' direction='in'/>
      <arg type='u' name='id' direction='out'/>
    </method>
    <method name='CloseNotification'>
      <arg type='u' name='id' direction='in'/>
    </method>
    <method name='GetCapabilities'>
      <arg type='as' name='capabilities' direction='out'/>
    </method>
    <method name='GetServerInformation'>
      <arg type='s' name='name' direction='out'/>
      <arg type='s' name='vendor' direction='out'/>
      <arg type='s' name='version' direction='out'/>
      <arg type='s' name='spec_version' direction='out'/>
    </method>
  </interface>
</node>
"""

class DBusNotificationServer:
    """
    Implements the standard org.freedesktop.Notifications DBus interface.
    """
    def __init__(self, on_notify_cb, on_close_cb):
        self.on_notify_cb = on_notify_cb
        self.on_close_cb = on_close_cb
        self.next_id = 1
        self._setup_service()

    def _setup_service(self):
        try:
            self.node_info = Gio.DBusNodeInfo.new_for_xml(DBUS_INTROSPECTION_XML)
            Gio.bus_own_name(
                Gio.BusType.SESSION,
                'org.freedesktop.Notifications',
                Gio.BusNameOwnerFlags.REPLACE,
                self._on_bus_acquired,
                None,
                None
            )
        except Exception as e:
            print(f"DBus setup error: {e}", file=sys.stderr)

    def _on_bus_acquired(self, connection, name):
        try:
            connection.register_object(
                '/org/freedesktop/Notifications',
                self.node_info.interfaces[0],
                self._handle_method_call,
                None,
                None
            )
        except Exception as e:
            print(f"Failed to register DBus object: {e}", file=sys.stderr)

    def _handle_method_call(self, conn, sender, path, iface, method, params, invocation, *args):
        if method == 'GetCapabilities':
            invocation.return_value(GLib.Variant('(as)', (['body', 'actions'],)))
        elif method == 'GetServerInformation':
            invocation.return_value(GLib.Variant('(ssss)', ('hyprdark-notifications', 'Hyprdark', '2.0', '1.2')))
        elif method == 'Notify':
            app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout = params.unpack()
            noti_id = self.next_id
            self.next_id += 1

            noti_dict = {
                'id': noti_id,
                'app_name': app_name or 'System',
                'app_icon': app_icon or '',
                'summary': summary or app_name,
                'body': body or '',
                'time': datetime.datetime.now()
            }
            GLib.idle_add(lambda: self.on_notify_cb(noti_dict))
            invocation.return_value(GLib.Variant('(u)', (noti_id,)))
        elif method == 'CloseNotification':
            nid = params.unpack()[0]
            GLib.idle_add(lambda: self.on_close_cb(nid))
            invocation.return_value(None)
