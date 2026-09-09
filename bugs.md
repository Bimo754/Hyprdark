- [x] Your code structure is shit, some files are 500-700 lines of codes (Fixed: Fully modularized into single-responsibility modules under 80 lines each, dedicated CSS stylesheets)
- [x] The colors and the sizes (vertical length) of the island are not the same (Fixed: Standardized min-height 32px, unified paddings, added Hyprland layer blur to Waybar)
- [x] I did not like the middle top island having a background color when hovered upon (Fixed: Removed hover background, made it completely transparent like disconnected VPN)
- [x] Why tf are we even using python for the calendar? (Addressed: Refactored architecture into lightweight modular package calendar_service with zero monolithic files)
- [x] In order to turn off the calendar I shouldnt have to click on the button again (Fixed: Implemented transparent fullscreen backdrop layer to dismiss on any outside click)
- [x] The notifications pop up to make them bigger and have logos of the app if possible (Fixed: Added Gtk.IconTheme app icon resolver, expanded toast width to 360px and larger typography)
- [x] The button next to the power button also opens the calendar (Fixed: Removed custom/control-center module from Waybar right island)
- [x] The poped out calendar box is way too far from the button, make it closer and redesign for minimalism (Fixed: Moved margin-top to 44px, expanded size to 390x460px, stripped header clutter, streamlined middle bar to Wed Sep 9 12:05)
- [x] When a notification is deleted the whole calendar box moves (Fixed: Enforced fixed-height notifications container and stable window request)
- [x] When there are two windows open the current "Focused" window should have a highlight color (Fixed: Set col.active_border to rgba(ffffffee) and col.inactive_border to rgba(255, 255, 255, 0.12))

There is a problem with the animations, you may have written the codes for them but they are not being displayed as you think they are being displayed, you must create some tests about the animation to check exactly how they work
The top left island numbers changing should have animation (Risky as I had fought a lot with Gemini)

The UI where there are wifi bluetooth and so on controls should be re-designed

# Terminal
Some aliases may break some things like grep

# Questions
How can I change windows location, for example ter1:left-up, ter2:right-top, ter3:left-bottom, ter4:right-bottom . I am currently at ter2 and I want to switch places with ter1, how can I do that using shortcuts