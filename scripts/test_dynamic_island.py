#!/usr/bin/env python3
# ==============================================================================
# Hyprdark - Dynamic Island Animation Testbed & Prototype
# Features:
# - True 165Hz VSync-synchronized animation via Gtk.Widget.add_tick_callback
# - Organic Apple Spring Physics solver (mass, stiffness, damping)
# - Real-time morphing between 5 states:
#     0: Resting Clock Capsule (180x34px)
#     1: Media Player Island (370x46px)
#     2: Volume Slider Island (260x36px)
#     3: Security Target Telemetry (300x36px)
#     4: Notification Toast Island (390x48px)
# - Interactive mouse click to trigger state transitions
# - Live FPS and frame-time benchmarking to prove smooth non-snapping motion
# ==============================================================================

import os
import sys
import math
import time
import signal
import argparse
import datetime
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, Gdk, GtkLayerShell, GLib
try:
    from gi.repository import GLibUnix
    signal_add = GLibUnix.signal_add
except ImportError:
    signal_add = GLib.unix_signal_add

PID_FILE = "/tmp/hyprdark_dynamic_island.pid"

# --- Apple Spring Physics Solver ---
class SpringSolver:
    """
    Second-order underdamped/critically-damped harmonic oscillator.
    Simulates authentic Apple iOS / macOS fluid spring physics.
    """
    def __init__(self, initial_value=180.0, stiffness=240.0, damping=20.0, mass=1.0):
        self.current = float(initial_value)
        self.target = float(initial_value)
        self.velocity = 0.0
        self.stiffness = stiffness
        self.damping = damping
        self.mass = mass
        self.epsilon = 0.3

    def set_target(self, target):
        self.target = float(target)

    def step(self, dt):
        """Advances physics by dt seconds. Returns True if still in motion."""
        # Cap dt to avoid numerical explosion if a frame lags
        dt = min(dt, 0.05)
        displacement = self.current - self.target
        spring_force = -self.stiffness * displacement
        damping_force = -self.damping * self.velocity
        acceleration = (spring_force + damping_force) / self.mass
        
        self.velocity += acceleration * dt
        self.current += self.velocity * dt

        # Settle condition
        if abs(displacement) < self.epsilon and abs(self.velocity) < self.epsilon:
            self.current = self.target
            self.velocity = 0.0
            return False
        return True


class DynamicIslandTestbed(Gtk.Window):
    def __init__(self, position_top=56, auto_cycle=False, benchmark=False):
        super().__init__()
        self.position_top = position_top
        self.auto_cycle = auto_cycle
        self.benchmark_mode = benchmark
        self.current_state = 0
        self.states = [
            {"name": "Resting Clock", "width": 180, "height": 34},
            {"name": "Media Player", "width": 370, "height": 46},
            {"name": "Volume Control", "width": 260, "height": 36},
            {"name": "Security Target", "width": 300, "height": 36},
            {"name": "Notification Alert", "width": 390, "height": 48},
        ]

        # Physics Solvers for Width and Height (Apple Fluid Spring constants)
        self.spring_w = SpringSolver(initial_value=self.states[0]["width"], stiffness=260.0, damping=22.0)
        self.spring_h = SpringSolver(initial_value=self.states[0]["height"], stiffness=300.0, damping=24.0)

        # Performance / Benchmarking telemetry
        self.last_frame_time = None
        self.frame_count = 0
        self.fps_sample_start = time.time()
        self.live_fps = 0.0
        self.frame_durations = []

        # Morph frame-by-frame recorder
        self._morph_in_progress = False
        self._morph_start_wall = None
        self._morph_start_clock = None
        self._morph_frames = []

        self._setup_layer_shell()
        self._apply_css()
        self._build_ui()

        # Connect frame tick callback dynamically on demand to ensure 0% idle CPU
        self._tick_id = None

        if self.auto_cycle:
            GLib.timeout_add(2600, self._on_auto_cycle_timer)

    def _setup_layer_shell(self):
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_namespace(self, "dynamic-island-test")
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, self.position_top)

    def _apply_css(self):
        css = b"""
        window.dynamic-island {
            background-color: rgba(18, 18, 22, 0.90);
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 999px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.65);
        }
        .island-inner {
            padding: 0 14px;
        }
        .lbl-clock {
            color: #ffffff;
            font-family: "JetBrainsMono Nerd Font", sans-serif;
            font-size: 12.5px;
            font-weight: 600;
        }
        .lbl-artist {
            color: rgba(255, 255, 255, 0.50);
            font-size: 11px;
        }
        .lbl-title {
            color: #ffffff;
            font-size: 12px;
            font-weight: 700;
        }
        .lbl-eq {
            color: #ffffff;
            font-size: 14px;
        }
        .progress-bar-bg {
            background: rgba(255, 255, 255, 0.12);
            border-radius: 999px;
            min-height: 4px;
        }
        .progress-bar-fill {
            background: #ffffff;
            border-radius: 999px;
            min-height: 4px;
        }
        .target-text {
            color: rgba(10, 132, 255, 0.95);
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 12px;
            font-weight: 700;
        }
        .noti-app {
            color: #ffffff;
            font-size: 11.5px;
            font-weight: 700;
        }
        .noti-preview {
            color: rgba(255, 255, 255, 0.70);
            font-size: 11px;
        }
        .fps-badge {
            color: rgba(255, 255, 255, 0.35);
            font-size: 9px;
            font-family: monospace;
        }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        self.get_style_context().add_class('dynamic-island')

    def _build_ui(self):
        # EventBox for interactive click handling
        self.event_box = Gtk.EventBox()
        self.event_box.set_visible_window(False)
        self.event_box.connect('button-press-event', self._on_click)

        # Root sizing box
        self.root_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.root_box.set_size_request(int(self.states[0]["width"]), int(self.states[0]["height"]))
        self.root_box.get_style_context().add_class('island-inner')

        # Stack widget to swap contents smoothly
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        self.stack.set_transition_duration(180)

        # --- View 0: Clock & Date ---
        self.view_clock = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.view_clock.set_valign(Gtk.Align.CENTER)
        self.view_clock.set_halign(Gtk.Align.CENTER)
        self.clock_lbl = Gtk.Label(label=datetime.datetime.now().strftime("󰸗 %a %b %-d    %H:%M"))
        self.clock_lbl.get_style_context().add_class('lbl-clock')
        self.view_clock.pack_start(self.clock_lbl, True, True, 0)
        self.stack.add_named(self.view_clock, "clock")
        GLib.timeout_add_seconds(1, self._update_clock)

        # --- View 1: Media Player ---
        self.view_media = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.view_media.set_valign(Gtk.Align.CENTER)
        disc_lbl = Gtk.Label(label="󰎆")
        disc_lbl.get_style_context().add_class('lbl-eq')
        self.view_media.pack_start(disc_lbl, False, False, 0)

        media_text_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        media_text_box.set_valign(Gtk.Align.CENTER)
        title_lbl = Gtk.Label(label="Starboy · The Weeknd")
        title_lbl.set_xalign(0.0)
        title_lbl.get_style_context().add_class('lbl-title')
        media_text_box.pack_start(title_lbl, False, False, 0)

        # Mini progress bar
        prog_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        prog_box.set_size_request(180, 4)
        prog_box.get_style_context().add_class('progress-bar-bg')
        prog_fill = Gtk.Box()
        prog_fill.set_size_request(90, 4)
        prog_fill.get_style_context().add_class('progress-bar-fill')
        prog_box.pack_start(prog_fill, False, False, 0)
        media_text_box.pack_start(prog_box, False, False, 0)

        self.view_media.pack_start(media_text_box, True, True, 0)
        eq_lbl = Gtk.Label(label=" ▃▅▇")
        eq_lbl.get_style_context().add_class('lbl-eq')
        self.view_media.pack_end(eq_lbl, False, False, 0)
        self.stack.add_named(self.view_media, "media")

        # --- View 2: Volume Control ---
        self.view_volume = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.view_volume.set_valign(Gtk.Align.CENTER)
        vol_icon = Gtk.Label(label="󰕾")
        vol_icon.get_style_context().add_class('lbl-eq')
        self.view_volume.pack_start(vol_icon, False, False, 0)

        vol_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        vol_bar.set_size_request(140, 6)
        vol_bar.get_style_context().add_class('progress-bar-bg')
        vol_fill = Gtk.Box()
        vol_fill.set_size_request(105, 6)
        vol_fill.get_style_context().add_class('progress-bar-fill')
        vol_bar.pack_start(vol_fill, False, False, 0)
        self.view_volume.pack_start(vol_bar, True, True, 0)

        vol_pct = Gtk.Label(label="75%")
        vol_pct.get_style_context().add_class('lbl-clock')
        self.view_volume.pack_end(vol_pct, False, False, 0)
        self.stack.add_named(self.view_volume, "volume")

        # --- View 3: Security Target ---
        self.view_target = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.view_target.set_valign(Gtk.Align.CENTER)
        tgt_icon = Gtk.Label(label="󰓾")
        tgt_icon.get_style_context().add_class('target-text')
        self.view_target.pack_start(tgt_icon, False, False, 0)

        tgt_lbl = Gtk.Label(label="TARGET: 10.10.11.23")
        tgt_lbl.get_style_context().add_class('target-text')
        self.view_target.pack_start(tgt_lbl, True, True, 0)

        cop_lbl = Gtk.Label(label="󰆏")
        cop_lbl.get_style_context().add_class('target-text')
        self.view_target.pack_end(cop_lbl, False, False, 0)
        self.stack.add_named(self.view_target, "target")

        # --- View 4: Notification Alert ---
        self.view_noti = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.view_noti.set_valign(Gtk.Align.CENTER)
        n_icon = Gtk.Label(label="󰂚")
        n_icon.get_style_context().add_class('lbl-eq')
        self.view_noti.pack_start(n_icon, False, False, 0)

        n_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        n_box.set_valign(Gtk.Align.CENTER)
        n_app = Gtk.Label(label="Discord · Alice")
        n_app.set_xalign(0.0)
        n_app.get_style_context().add_class('noti-app')
        n_box.pack_start(n_app, False, False, 0)
        n_msg = Gtk.Label(label="Check the new design space")
        n_msg.set_xalign(0.0)
        n_msg.get_style_context().add_class('noti-preview')
        n_box.pack_start(n_msg, False, False, 0)
        self.view_noti.pack_start(n_box, True, True, 0)

        n_x = Gtk.Label(label="✕")
        n_x.get_style_context().add_class('lbl-artist')
        self.view_noti.pack_end(n_x, False, False, 0)
        self.stack.add_named(self.view_noti, "noti")

        self.root_box.pack_start(self.stack, True, True, 0)
        self.event_box.add(self.root_box)
        self.add(self.event_box)

        self.stack.set_visible_child_name("clock")
        self.show_all()

    def _update_clock(self):
        self.clock_lbl.set_text(datetime.datetime.now().strftime("󰸗 %a %b %-d    %H:%M"))
        return True

    def set_state(self, state_idx):
        self.current_state = state_idx % len(self.states)
        st = self.states[self.current_state]
        self.spring_w.set_target(st["width"])
        self.spring_h.set_target(st["height"])

        names = ["clock", "media", "volume", "target", "noti"]
        self.stack.set_visible_child_name(names[self.current_state])
        print(f"[DynamicIsland] Morphing to State {self.current_state}: {st['name']} ({st['width']}x{st['height']}px)")

        self._morph_in_progress = True
        self._morph_start_wall = time.time()
        self._morph_frames = []

        if self._tick_id is None:
            self.last_frame_time = None
            self._tick_id = self.add_tick_callback(self._on_frame_tick)

    def _on_click(self, widget, event):
        self.set_state(self.current_state + 1)
        return True

    def _on_auto_cycle_timer(self):
        self.set_state(self.current_state + 1)
        return True

    def _on_frame_tick(self, widget, frame_clock):
        now = frame_clock.get_frame_time() / 1e6 # seconds
        if self.last_frame_time is None:
            self.last_frame_time = now
            return True

        dt = now - self.last_frame_time
        self.last_frame_time = now

        # Update physics
        active_w = self.spring_w.step(dt)
        active_h = self.spring_h.step(dt)

        if active_w or active_h:
            cur_w = int(round(self.spring_w.current))
            cur_h = int(round(self.spring_h.current))
            # Apply smooth size to widget
            self.root_box.set_size_request(cur_w, cur_h)
            self.queue_resize()
            if self._morph_in_progress:
                elapsed = (time.time() - self._morph_start_wall) * 1000.0
                self._morph_frames.append((elapsed, cur_w, cur_h, dt))
            return True
        else:
            # Animation complete: log benchmark and detach tick callback
            if self._morph_in_progress:
                self._morph_in_progress = False
                total_duration = (time.time() - self._morph_start_wall) * 1000.0
                n_frames = len(self._morph_frames)
                fps = (n_frames / (total_duration / 1000.0)) if total_duration > 0 else 0
                st = self.states[self.current_state]
                print(f"[Benchmark] Settled at {st['width']}x{st['height']}px in {total_duration:.1f}ms across {n_frames} frames ({fps:.1f} FPS)")
                if self.benchmark_mode and n_frames > 0:
                    print("  Sample Frame Progression:")
                    step = max(1, n_frames // 8)
                    for i in range(0, n_frames, step):
                        el_ms, w, h, f_dt = self._morph_frames[i]
                        print(f"    t={el_ms:5.1f}ms: width={w:3d}px, height={h:2d}px | frame_dt={f_dt*1000:.2f}ms")
                    last_el, last_w, last_h, last_dt = self._morph_frames[-1]
                    print(f"    t={last_el:5.1f}ms: width={last_w:3d}px, height={last_h:2d}px (FINAL SETTLE)")

            self._tick_id = None
            return False


def main():
    parser = argparse.ArgumentParser(description="Hyprdark Dynamic Island Animation Testbed")
    parser.add_argument("--auto", action="store_true", help="Automatically cycle through all morph states")
    parser.add_argument("--top", type=int, default=56, help="Top margin in pixels (default: 56px, below Waybar)")
    parser.add_argument("--state", type=int, default=0, help="Initial state (0-4)")
    parser.add_argument("--benchmark", action="store_true", help="Record and log frame-by-frame morph benchmark")
    parser.add_argument("--next", action="store_true", help="Signal running testbed to cycle to next state")
    parser.add_argument("--prev", action="store_true", help="Signal running testbed to cycle to prev state")
    parser.add_argument("--stop", action="store_true", help="Stop running testbed")
    args = parser.parse_args()

    # Client mode: signal running daemon
    if args.next or args.prev or args.stop:
        if not os.path.exists(PID_FILE):
            print(f"No running testbed found (no {PID_FILE}).")
            sys.exit(1)
        try:
            with open(PID_FILE, 'r') as f:
                target_pid = int(f.read().strip())
        except Exception as e:
            print(f"Failed to read PID file: {e}")
            sys.exit(1)

        sig = signal.SIGUSR1 if args.next else (signal.SIGUSR2 if args.prev else signal.SIGTERM)
        try:
            os.kill(target_pid, sig)
            action = "next" if args.next else ("prev" if args.prev else "stop")
            print(f"Dispatched {action} signal to Dynamic Island PID {target_pid}")
            sys.exit(0)
        except ProcessLookupError:
            print(f"Process {target_pid} is no longer running.")
            if os.path.exists(PID_FILE):
                os.remove(PID_FILE)
            sys.exit(1)

    # Server / Daemon mode
    try:
        with open(PID_FILE, 'w') as f:
            f.write(str(os.getpid()))
    except Exception as e:
        print(f"Warning: Could not write PID file: {e}")

    app = DynamicIslandTestbed(position_top=args.top, auto_cycle=args.auto, benchmark=args.benchmark)
    if args.state != 0:
        app.set_state(args.state)

    def on_usr1(*_):
        app.set_state(app.current_state + 1)
        return True

    def on_usr2(*_):
        app.set_state(app.current_state - 1)
        return True

    def on_quit(*_):
        Gtk.main_quit()
        return False

    signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR1, on_usr1)
    signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR2, on_usr2)
    signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, on_quit)
    signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, on_quit)

    print("=================================================================")
    print(" Hyprdark Dynamic Island Animation Testbed Running")
    print(f" Initial State: {app.states[app.current_state]['name']}")
    print(" Control via: python3 scripts/test_dynamic_island.py --next")
    print(" Click on the floating island to morph into the next state!")
    print("=================================================================")

    try:
        Gtk.main()
    except KeyboardInterrupt:
        pass
    finally:
        if os.path.exists(PID_FILE):
            try:
                os.remove(PID_FILE)
            except Exception:
                pass

if __name__ == '__main__':
    main()
