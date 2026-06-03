```
nixos-configuration/
├── .gitignore
├── FUNDING.yml
├── README.md
├── config/
│   ├── fonts/
│   │   ├── JetBrainsMono/
│   │   │   ├── JetBrainsMono-Bold.ttf
│   │   │   ├── JetBrainsMono-BoldItalic.ttf
│   │   │   ├── JetBrainsMono-ExtraBold.ttf
│   │   │   ├── JetBrainsMono-ExtraBoldItalic.ttf
│   │   │   ├── JetBrainsMono-ExtraLight.ttf
│   │   │   ├── JetBrainsMono-ExtraLightItalic.ttf
│   │   │   ├── JetBrainsMono-Italic.ttf
│   │   │   ├── JetBrainsMono-Light.ttf
│   │   │   ├── JetBrainsMono-LightItalic.ttf
│   │   │   ├── JetBrainsMono-Medium.ttf
│   │   │   ├── JetBrainsMono-MediumItalic.ttf
│   │   │   ├── JetBrainsMono-Regular.ttf
│   │   │   ├── JetBrainsMono-Thin.ttf
│   │   │   ├── JetBrainsMono-ThinItalic.ttf
│   │   │   ├── JetBrainsMonoNL-Bold.ttf
│   │   │   ├── JetBrainsMonoNL-BoldItalic.ttf
│   │   │   ├── JetBrainsMonoNL-ExtraBold.ttf
│   │   │   ├── JetBrainsMonoNL-ExtraBoldItalic.ttf
│   │   │   ├── JetBrainsMonoNL-ExtraLight.ttf
│   │   │   ├── JetBrainsMonoNL-ExtraLightItalic.ttf
│   │   │   ├── JetBrainsMonoNL-Italic.ttf
│   │   │   ├── JetBrainsMonoNL-Light.ttf
│   │   │   ├── JetBrainsMonoNL-LightItalic.ttf
│   │   │   ├── JetBrainsMonoNL-Medium.ttf
│   │   │   ├── JetBrainsMonoNL-MediumItalic.ttf
│   │   │   ├── JetBrainsMonoNL-Regular.ttf
│   │   │   ├── JetBrainsMonoNL-Thin.ttf
│   │   │   └── JetBrainsMonoNL-ThinItalic.ttf
│   │   └── iosevka-nerd-font.ttf
│   ├── programs/
│   │   ├── cava/
│   │   │   ├── config
│   │   │   └── default.nix
│   │   ├── kitty/
│   │   │   ├── default.nix
│   │   │   └── kitty.conf
│   │   ├── matugen/
│   │   │   ├── config.toml
│   │   │   ├── default.nix
│   │   │   └── templates/
│   │   │       ├── cava-colors.ini.template
│   │   │       ├── discord.css.template
│   │   │       ├── firefox.css
│   │   │       ├── gtk.css.template
│   │   │       ├── hyprland.conf.template
│   │   │       ├── kitty-colors.conf.template
│   │   │       ├── nvim-colors.lua.template
│   │   │       ├── qs_colors.json.template
│   │   │       ├── qt-style.qss.template
│   │   │       ├── qtct.conf.template
│   │   │       ├── swayosd.css.template
│   │   │       └── websites/
│   │   │           ├── github.css.template
│   │   │           └── youtube.css.template
│   │   ├── neovim/
│   │   │   ├── default.nix
│   │   │   └── nvim/
│   │   │       └── init.lua
│   │   ├── plymouth/
│   │   │   ├── default.nix
│   │   │   └── simple/
│   │   │       ├── resources/
│   │   │       │   ├── animation-001.png
│   │   │       │   ├── bullet.png
│   │   │       │   ├── capslock.png
│   │   │       │   ├── entry.png
│   │   │       │   ├── keyboard.png
│   │   │       │   ├── keymap-render.png
│   │   │       │   ├── lock.png
│   │   │       │   └─ progress-001.png
│   │   │       ├── screenshot.png
│   │   │       └── simple.plymouth
│   │   ├── rofi/
│   │   │   ├── config.rasi
│   │   │   └── default.nix
│   │   ├── swayosd/
│   │   │   └── default.nix
│   │   └── zsh/
│   │       ├── default.nix
│   │       └── zsh-init.sh
│   └── sessions/
│       └── hyprland/
│           ├── config/
│           │   ├── autostart.conf
│           │   ├── env.conf
│           │   ├── keybindings.conf
│           │   ├── monitors.conf
│           │   ├── rules.conf
│           │   ├── settings.conf
│           │   └── variables.conf
│           ├── default.nix
│           ├── hypridle.nix
│           ├── hyprland.conf
│           ├── scripts/
│           │   ├── caching.sh
│           │   ├── exit.sh
│           │   ├── lock.sh
│           │   ├── qs_manager.sh
│           │   ├── quickshell/
│           │   │   ├── Caching.qml
│           │   │   ├── Config.qml
│           │   │   ├── Floating.qml
│           │   │   ├── Lock.qml
│           │   │   ├── Main.qml
│           │   │   ├── MatugenColors.qml
│           │   │   ├── Scaler.qml
│           │   │   ├── ScreenshotOverlay.qml
│           │   │   ├── Shell.qml
│           │   │   ├── SysData.qml
│           │   │   ├── TopBar.qml
│           │   │   ├── WindowRegistry.js
│           │   │   ├── applauncher/
│           │   │   │   ├── appLauncher.qml
│           │   │   │   └── app_fetcher.py
│           │   │   ├── battery/
│           │   │   │   └── BatteryPopup.qml
│           │   │   ├── calendar/
│           │   │   │   ├── CalendarPopup.qml
│           │   │   │   ├── diary_manager.sh
│           │   │   │   ├── schedule/
│           │   │   │   │   ├── get_schedule.py
│           │   │   │   │   ├── schedule_manager.sh
│           │   │   │   │   └── shell.nix
│           │   │   │   └── weather.sh
│           │   │   ├── clipboard/
│           │   │   │   ├── ClipboardManager.qml
│           │   │   │   └── clip_fetcher.py
│           │   │   ├── focustime/
│           │   │   │   ├── FocusTimePopup.qml
│           │   │   │   ├── focus_daemon.py
│           │   │   │   ├── get_stats.py
│           │   │   │   └── launch_daemon.sh
│           │   │   ├── guide/
│           │   │   │   ├── GuidePopup.qml
│           │   │   │   └── previews/
│           │   │   │       ├── preview_battery.png
│           │   │   │       ├── preview_calendar.png
│           │   │   │       ├── preview_focustime.png
│           │   │   │       ├── preview_monitors.png
│           │   │   │       ├── preview_music.png
│           │   │   │       ├── preview_network.png
│           │   │   │       ├── preview_stewart.png
│           │   │   │       ├── preview_volume.png
│           │   │   │       └── preview_wallpaper.png
│           │   │   ├── monitors/
│           │   │   │   └── MonitorPopup.qml
│           │   │   ├── movies/
│           │   │   │   └── MovieWidget.qml
│           │   │   ├── music/
│           │   │   │   ├── MusicPopup.qml
│           │   │   │   ├── equalizer.sh
│           │   │   │   ├── music_info.sh
│           │   │   │   └── player_control.sh
│           │   │   ├── network/
│           │   │   │   ├── NetworkPopup.qml
│           │   │   │   ├── bluetooth_panel_logic.sh
│           │   │   │   ├── eth_panel_logic.sh
│           │   │   │   ├── sounds/
│           │   │   │   │   ├── connect.wav
│           │   │   │   │   ├── disconnect.wav
│           │   │   │   │   ├── power_off.wav
│           │   │   │   │   ├── power_on.wav
│           │   │   │   │   └── switch.wav
│           │   │   │   └── wifi_panel_logic.sh
│           │   │   ├── notifications/
│           │   │   │   └── NotificationPopups.qml
│           │   │   ├── quickactions/
│           │   │   │   ├── DrawAction.qml
│           │   │   │   ├── SystemUsage.qml
│           │   │   │   └── Timer.qml
│           │   │   ├── settings/
│           │   │   │   └── SettingsPopup.qml
│           │   │   ├── stewart/
│           │   │   │   └── stewart.qml
│           │   │   ├── updater/
│           │   │   │   └── UpdaterPopup.qml
│           │   │   ├── volume/
│           │   │   │   ├── VolumePopup.qml
│           │   │   │   ├── audio_control.sh
│           │   │   │   └── get_audio_state.py
│           │   │   ├── wallpaper/
│           │   │   │   ├── WallpaperPicker.qml
│           │   │   │   ├── ddg_search.sh
│           │   │   │   ├── get_ddg_links.py
│           │   │   │   └── matugen_reload.sh
│           │   │   └── watchers/
│           │   │       ├── audio_fetch.sh
│           │   │       ├── audio_wait.sh
│           │   │       ├── battery_fetch.sh
│           │   │       ├── battery_wait.sh
│           │   │       ├── bt_fetch.sh
│           │   │       ├── bt_wait.sh
│           │   │       ├── kb_fetch.sh
│           │   │       ├── kb_wait.sh
│           │   │       ├── network_fetch.sh
│           │   │       ├── network_wait.sh
│           │   │       └── sys_fetcher.sh
│           │   ├── reload.sh
│           │   ├── screenshot.sh
│           │   ├── volume_listener.sh
│           │   └── workspaces.sh
│           └── templates/
│               ├── autostart.conf.template
│               ├── keybinds.conf.template
│               ├── monitors.conf.template
│               └── settings.conf.template
├── configuration.nix
├── hardware-configuration.nix
├── home.nix
└── previews/
    ├── screenshot1.png
    ├── screenshot10.png
    ├── screenshot2.png
    ├── screenshot3.png
    ├── screenshot4.png
    ├── screenshot5.png
    ├── screenshot6.png
    ├── screenshot7.png
    ├── screenshot8.png
    └── screenshot9.png
```