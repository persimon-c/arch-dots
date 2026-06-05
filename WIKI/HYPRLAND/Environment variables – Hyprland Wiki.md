Configuring Advanced and Cool Environment variables 

Environment variables 

Note 

Looking for the old hyprlang syntax? Check the 0.54 wiki pages. Since Hyprland 0.55, hyprlang is deprecated in favor of lua. 

Note 

uwsm users should avoid placing environment variables in the hyprland.lua file. Instead, use \~/.config/uwsm/env for theming, xcursor, Nvidia and toolkit variables, and \~/.config/uwsm/env-hyprland for HYPR\* and AQ\_\* variables. 

The format is export KEY=VAL . 

export XCURSOR\_SIZE=24 

See uwsm readme for additional information. 

You can use the hl.env() method to set environment variables prior to the initialization of the Display Server, e.g.: 

hl.env("GTK\_THEME", "Nord")

Note 

When referencing existing environment variables like $XDG\_RUNTIME\_DIR , use os.getenv() , eg.: hl.env("SSH\_AUTH\_SOCK", os.getenv("XDG\_RUNTIME\_DIR").."/ssh-agent.socket") 

Warning 

Please avoid putting those environment variables in /etc/environment . 

That will cause all sessions (including Xorg ones) to pick up your Wayland-specific environment on traditional Linux distros. 

Hyprland Environment Variables 

hl.env("HYPRLAND\_TRACE", "1") \- Enables more verbose logging. 

hl.env("HYPRLAND\_NO\_RT", "1") \- Disables realtime priority setting by Hyprland. hl.env("HYPRLAND\_NO\_SD\_NOTIFY", "1") \- If systemd, disables the sd\_notify calls. 

hl.env("HYPRLAND\_NO\_SD\_VARS", "1") \- Disables management of variables in systemd and dbus activation environments. 

hl.env("HYPRLAND\_CONFIG", "/path/to/hyprland.lua") \- Specifies where you want your Hyprland configuration. 

Aquamarine Environment Variables 

hl.env("AQ\_TRACE", "1") \- Enables more verbose logging. 

hl.env("AQ\_DRM\_DEVICES", "...") \- Set an explicit list of DRM devices (GPUs) to use. It’s a colon separated list of paths, with the first being the primary. E.g.: /dev/dri/card1:/dev/dri/card0 

hl.env("AQ\_FORCE\_LINEAR\_BLIT", "0") \- Disables forcing linear explicit modifiers on Multi-GPU buffers to potentially workaround Nvidia issues.   
hl.env("AQ\_MGPU\_NO\_EXPLICIT", "1") \- Disables explicit syncing on mgpu buffers. hl.env("AQ\_NO\_MODIFIERS", "1") \- Disables modifiers for DRM buffers. 

hl.env("AQ\_NO\_KMS\_REQUIREMENT", "1") \- Disable KMS requirement for starting on headless GPUs. Toolkit Backend Variables 

hl.env("GDK\_BACKEND", "wayland,x11,\*") \- GTK: Use Wayland if available; if not, try X11 and then any other GDK backend. 

hl.env("QT\_QPA\_PLATFORM", "wayland;xcb") \- Qt: Use Wayland if available, fall back to X11 if not. 

hl.env("SDL\_VIDEODRIVER", "wayland") \- Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues 

hl.env("CLUTTER\_BACKEND", "wayland") \- Clutter package already has Wayland enabled, this variable will force Clutter applications to try and use the Wayland backend 

XDG Specifications 

hl.env("XDG\_CURRENT\_DESKTOP", "Hyprland") 

hl.env("XDG\_SESSION\_TYPE", "wayland") 

hl.env("XDG\_SESSION\_DESKTOP", "Hyprland") 

XDG specific environment variables are often detected through portals and applications that may set those for you, however it is not a bad idea to set them explicitly. 

If your desktop portal is malfunctioning for seemingly no reason (no errors), it’s likely your XDG env isn’t set correctly. 

Note 

uwsm users don’t need to explicitly set XDG environment variables, as uwsm sets them automatically. 

Qt Variables 

hl.env("QT\_AUTO\_SCREEN\_SCALE\_FACTOR", "1") \- (From the Qt documentation) enables automatic scaling, based on the monitor’s pixel density 

hl.env("QT\_QPA\_PLATFORM", "wayland;xcb") \- Tell Qt applications to use the Wayland backend, and fall back to X11 if Wayland is unavailable 

hl.env("QT\_WAYLAND\_DISABLE\_WINDOWDECORATION", "1") \- Disables window decorations on Qt applications 

hl.env("QT\_QPA\_PLATFORMTHEME", "qt5ct") \- Tells Qt based applications to pick your theme from qt5ct, use with Kvantum. 

NVIDIA Specific 

To force GBM as a backend, set the following environment variables: 

hl.env("GBM\_BACKEND", "nvidia-drm") 

hl.env("\_\_GLX\_VENDOR\_LIBRARY\_NAME", "nvidia") 

See Archwiki Wayland Page for more details on those variables. 

hl.env("LIBVA\_DRIVER\_NAME", "nvidia") \- Hardware acceleration on NVIDIA GPUs See Archwiki Hardware Acceleration Page for details and necessary values before setting this variable. \_\_GL\_GSYNC\_ALLOWED \- Controls if G-Sync capable monitors should use Variable Refresh Rate (VRR)  
See Nvidia Documentation for details. 

\_\_GL\_VRR\_ALLOWED \- Controls if Adaptive Sync should be used. Recommended to set as “0” to avoid having problems on some games. 

hl.env("AQ\_NO\_ATOMIC", "1") \- use legacy DRM interface instead of atomic mode setting. NOT recommended. 

Theming Related Variables 

GTK\_THEME \- Set a GTK theme manually, for those who want to avoid appearance tools such as lxappearance or nwg-look. 

XCURSOR\_THEME \- Set your cursor theme. The theme needs to be installed and readable by your user. XCURSOR\_SIZE \- Set cursor size. See here for why you might want this variable set. 

Last updated on June 2, 2026