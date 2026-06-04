Configuring Basics Autostart 

Autostart 

Note 

Looking for the old hyprlang syntax? Check the 0.54 wiki pages. Since Hyprland 0.55, hyprlang is deprecated in favor of lua. 

Autostarting apps can be done by executing things on the hyprland.start event: 

hl.on("hyprland.start", **function** () 

hl.exec\_cmd(terminal) 

hl.exec\_cmd("nm-applet") 

hl.exec\_cmd("waybar & hyprpaper & firefox") \-- Execute waybar, hyprpaper, firefox **end**)

hl.exec\_cmd() will spawn an asynchronous process, so there is no need for & disown at the end. In the same vein, you can spawn processes on exit by listening to hyprland.shutdown . See more about hl.on over at Expanding Functionality 

Last updated on June 2, 2026 