- The arch logo's highlighted background when mouse hovers upon it is not centered, like when the highlight lights up I can see the logo being kinda a little more shifted to the right than it should be
- [x] **Animation Technical Audit & Dynamic Island Testbed** (`scripts/test_dynamic_island.py`):
  - **GTK3 CSS Limitation Confirmed**: Waybar's GTK 3.24 CSS engine (`gtkcsstransition.c`) *only* supports transitions for color and opacity. Width, height, margin, and padding transitions are completely unsupported in GTK3 CSS and will snap or step abruptly.
  - **Fluid Physics Engine Created**: Built `scripts/test_dynamic_island.py` using `GtkLayerShell` + `Gtk.Widget.add_tick_callback` synced directly to the Wayland compositor's VSync clock (tested up to 165Hz on eDP-1).
  - **Authentic Apple Spring Physics**: Implemented second-order harmonic oscillator ($m=1.0, k=260.0, c=22.0$) with continuous underdamped spring overshoot and recoil.
  - **Verified 5 Morphing States**:
    1. Resting Clock Capsule (180x34px)
    2. Media Player (370x46px)
    3. Volume Control Slider (260x36px)
    4. Security Target Telemetry (300x36px)
    5. Notification Toast Alert (390x48px)
  - **Benchmarked Frame Rates**: Transition morphs benchmarked at 88.5–100.1 FPS across ~50 intermediate continuous frames with zero snap/jitter.
  - **Zero Idle CPU**: Dynamically connects tick callback during transitions and detaches on settle (0.0% idle CPU).
  - **CLI Control**: `python3 scripts/test_dynamic_island.py --next` / `--prev` / `--stop` / `--benchmark`.
- [ ] Top-left island workspace lighting artifact: active workspace 1 diffuse drop shadow (`box-shadow: 0 0 10px rgba(...)`) clips against `#workspaces` container box bounds creating a faint square halo. (Ready to eliminate diffuse glow and retain inner specular bevel when approved).
- The top left island numbers changing should have animation (Risky as I had fought a lot with Gemini)

The UI where there are wifi bluetooth and so on controls should be re-designed

# Terminal
Some aliases may break some things like grep

# Questions
How can I change windows location, for example ter1:left-up, ter2:right-top, ter3:left-bottom, ter4:right-bottom . I am currently at ter2 and I want to switch places with ter1, how can I do that using shortcuts