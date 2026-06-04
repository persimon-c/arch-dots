Configuring Advanced and Cool Notifications 

Notifications 

Note 

Looking for the old hyprlang syntax? Check the 0.54 wiki pages. Since Hyprland 0.55, hyprlang is deprecated in favor of lua. 

This page describes Hyprland’s built-in lightweight notifications. 

Note 

Hyprland’s built-in notifications are not meant to handle your system notifications. They are much simpler, text-only popups in the corner of your monitor. 

Lua 

In lua, notifications are exposed via the hl.notification module. 

Functions 

hl.notification.create({ text, duration, icon?, color?, font\_size? }) → HL.Notification → Push a notification 

hl.notification.get() → Get a table of all active notifications as HL.Notification objects Hyprctl 

From hyprctl, you can create a notification with the hyprctl notify command: 

hyprctl notify **\[**ICON**\] \[**TIME\_MS**\] \[**COLOR**\] \[**MESSAGE**\]**

See more in Using Hyprctl 

Last updated on June 2, 2026 