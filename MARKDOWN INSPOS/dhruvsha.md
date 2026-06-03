```
shell/
├── README.md
├── cava/
│   ├── config
│   ├── shaders/
│   │   ├── bar_spectrum.frag
│   │   ├── eye_of_phi.frag
│   │   ├── northern_lights.frag
│   │   ├── pass_through.vert
│   │   ├── spectrogram.frag
│   │   └── winamp_line_style_spectrum.frag
│   └── themes/
│       ├── solarized_dark
│       └── tricolor
├── hypr/
│   ├── colors.conf
│   ├── hyprland.conf
│   ├── hyprland.conf.save
│   └── hyprlock.conf
├── kitty/
│   ├── colors.conf
│   └── kitty.conf
├── matugen/
│   ├── config.toml
│   └── templates/
│       ├── GTK.css
│       ├── cava
│       ├── colors.css
│       ├── hyprland.conf
│       ├── kitty.conf
│       ├── quickshell.json.hbs
│       ├── rofi-color.rasi
│       ├── sway.css
│       ├── swayosd.css
│       └── waybar.css
├── previews/
│   └── rice-screenshots/
│       ├── pic1.png
│       ├── pic2.png
│       ├── pic3.png
│       ├── pic4.png
│       ├── pic5.png
│       ├── pic6.png
│       ├── pic7.png
│       └── pic8.png
├── quickshell/
│   ├── .idea/
│   │   ├── .gitignore
│   │   ├── modules.xml
│   │   └── quickshell.iml
│   ├── Core/
│   │   └── Icons.qml
│   ├── Lock.qml
│   ├── Osd/
│   │   └── OsdWindow.qml
│   ├── README.md
│   ├── Widgets/
│   │   ├── Icon.qml
│   │   ├── Tray.qml
│   │   └── TrayContextMenu.qml
│   ├── aikira/
│   │   ├── Aikira.qml
│   │   ├── Api.qml
│   │   ├── AppState.qml
│   │   ├── components/
│   │   │   ├── CharacterBrowser.qml
│   │   │   ├── CharacterCard.qml
│   │   │   ├── CharacterEditor.qml
│   │   │   ├── ChatPanel.qml
│   │   │   ├── ConversationItem.qml
│   │   │   ├── ErrorToast.qml
│   │   │   ├── InputBar.qml
│   │   │   ├── MessageBubble.qml
│   │   │   ├── PersonaSelector.qml
│   │   │   ├── ProxyDropdown.qml
│   │   │   ├── ProxyManager.qml
│   │   │   ├── Sidebar.qml
│   │   │   └── SidebarIconBtn.qml
│   │   └── qmldir
│   ├── colors/
│   │   ├── Colors.json
│   │   ├── Colors.qml
│   │   └── qmldir
│   ├── components/
│   │   ├── ActionButton.qml
│   │   ├── AvatarPicker.qml
│   │   ├── Calendar.qml
│   │   ├── CavaBars.qml
│   │   ├── ClipboardManager.qml
│   │   ├── Clock.qml
│   │   ├── ConfigureCategory.qml
│   │   ├── CreateCategory.qml
│   │   ├── GhCalendar.qml
│   │   ├── GhPopout.qml
│   │   ├── InfoRow.qml
│   │   ├── MediaControl.qml
│   │   ├── NotesDrawer.qml
│   │   ├── OllamaChat.qml
│   │   ├── Popout.qml
│   │   ├── PowerMenu.qml
│   │   ├── ScreenTools.qml
│   │   ├── SemiCircularGraph.qml
│   │   ├── Shangles.qml
│   │   ├── SliderRow.qml
│   │   ├── StatBar.qml
│   │   ├── SystemGraphs.qml
│   │   ├── TabButton.qml
│   │   ├── TimerComponent.qml
│   │   ├── ToggleTile.qml
│   │   └── Visualizer.qml
│   ├── config/
│   │   ├── Appearance.qml
│   │   └── AppearanceConfig.qml
│   ├── files/
│   │   ├── emoji.json
│   │   └── kaomoji.json
│   ├── modules/
│   │   ├── anime/
│   │   │   ├── AnimePanel.qml
│   │   │   └── components/
│   │   │       ├── BrowseView.qml
│   │   │       ├── DetailView.qml
│   │   │       └── LibraryView.qml
│   │   ├── bar/
│   │   │   ├── TopBar.qml
│   │   │   └── components/
│   │   │       ├── Battery.qml
│   │   │       ├── Bluetooth.qml
│   │   │       ├── Clock.qml
│   │   │       ├── Cpu.qml
│   │   │       ├── MediaPill.qml
│   │   │       ├── Memory.qml
│   │   │       ├── Network.qml
│   │   │       ├── SystemTray.qml
│   │   │       ├── Temp.qml
│   │   │       ├── Volume.qml
│   │   │       └── Workspaces.qml
│   │   ├── calendar/
│   │   │   ├── CalendarWindow.qml
│   │   │   └── ClockWindow.qml
│   │   ├── control/
│   │   │   ├── ControlCenter.qml
│   │   │   ├── Header.qml
│   │   │   ├── InfoSection.qml
│   │   │   ├── NotificationToasts.qml
│   │   │   ├── Notifications.qml
│   │   │   ├── PowerSection.qml
│   │   │   ├── QuickSettings.qml
│   │   │   ├── SinkSelector.qml
│   │   │   ├── SliderSection.qml
│   │   │   └── StatsSection.qml
│   │   ├── launcher/
│   │   │   └── LauncherWindow.qml
│   │   ├── manga/
│   │   │   ├── MangaReader.qml
│   │   │   └── components/
│   │   │       ├── BrowseView.qml
│   │   │       ├── DetailView.qml
│   │   │       ├── LibraryView.qml
│   │   │       └── ReaderView.qml
│   │   ├── media/
│   │   │   ├── CavaPanel.qml
│   │   │   └── MediaPanel.qml
│   │   ├── network/
│   │   │   ├── BluetoothPanel.qml
│   │   │   ├── NetworkPanel.qml
│   │   │   └── WifiPanel.qml
│   │   ├── novel/
│   │   │   ├── NovelReader.qml
│   │   │   └── components/
│   │   │       ├── BrowseView.qml
│   │   │       ├── DetailView.qml
│   │   │       ├── LibraryView.qml
│   │   │       └── ReaderView.qml
│   │   ├── switcher/
│   │   │   ├── SearchBox.qml
│   │   │   ├── WindowSwitcher.qml
│   │   │   └── WindowThumbnail.qml
│   │   ├── system/
│   │   │   └── SystemPanel.qml
│   │   └── wallpaper/
│   │       ├── WallhavenPanel.qml
│   │       ├── WallhavenWrapper.qml
│   │       ├── Wallpaper.qml
│   │       └── wp-script.sh
│   ├── notes.conf
│   ├── quotes/
│   │   ├── RandomQuote.qml
│   │   └── quotes.txt
│   ├── scripts/
│   │   ├── .gitignore
│   │   ├── __pycache__/
│   │   │   └── anime_server.cpython-314.pyc
│   │   ├── aikira/
│   │   │   ├── aikira-stream.py
│   │   │   ├── aikira.service
│   │   │   ├── alembic.ini
│   │   │   ├── alembic/
│   │   │   │   ├── __pycache__/
│   │   │   │   │   └── env.cpython-312.pyc
│   │   │   │   ├── env.py
│   │   │   │   ├── script.py.mako
│   │   │   │   └── versions/
│   │   │   │       ├── 0001_initial.py
│   │   │   │       └── __pycache__/
│   │   │   │           └── 0001_initial.cpython-312.pyc
│   │   │   ├── app/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── __pycache__/
│   │   │   │   │   ├── __init__.cpython-312.pyc
│   │   │   │   │   ├── config.cpython-312.pyc
│   │   │   │   │   └── main.cpython-312.pyc
│   │   │   │   ├── config.py
│   │   │   │   ├── db/
│   │   │   │   │   ├── __init__.py
│   │   │   │   │   ├── __pycache__/
│   │   │   │   │   │   ├── __init__.cpython-312.pyc
│   │   │   │   │   │   └── session.cpython-312.pyc
│   │   │   │   │   └── session.py
│   │   │   │   ├── main.py
│   │   │   │   ├── models/
│   │   │   │   │   ├── __init__.py
│   │   │   │   │   ├── __pycache__/
│   │   │   │   │   │   ├── __init__.cpython-312.pyc
│   │   │   │   │   │   └── models.cpython-312.pyc
│   │   │   │   │   └── models.py
│   │   │   │   ├── routers/
│   │   │   │   │   ├── __init__.py
│   │   │   │   │   ├── __pycache__/
│   │   │   │   │   │   ├── __init__.cpython-312.pyc
│   │   │   │   │   │   ├── characters.cpython-312.pyc
│   │   │   │   │   │   ├── chat.cpython-312.pyc
│   │   │   │   │   │   ├── conversations.cpython-312.pyc
│   │   │   │   │   │   ├── personas.cpython-312.pyc
│   │   │   │   │   │   └── proxies.cpython-312.pyc
│   │   │   │   │   ├── characters.py
│   │   │   │   │   ├── chat.py
│   │   │   │   │   ├── conversations.py
│   │   │   │   │   ├── personas.py
│   │   │   │   │   └── proxies.py
│   │   │   │   ├── schemas/
│   │   │   │   │   ├── __init__.py
│   │   │   │   │   ├── __pycache__/
│   │   │   │   │   │   ├── __init__.cpython-312.pyc
│   │   │   │   │   │   └── schemas.cpython-312.pyc
│   │   │   │   │   └── schemas.py
│   │   │   │   └── services/
│   │   │   │       ├── __init__.py
│   │   │   │       ├── __pycache__/
│   │   │   │       │   ├── __init__.cpython-312.pyc
│   │   │   │       │   ├── character_service.cpython-312.pyc
│   │   │   │       │   ├── conversation_service.cpython-312.pyc
│   │   │   │       │   ├── persona_service.cpython-312.pyc
│   │   │   │       │   └── proxy_service.cpython-312.pyc
│   │   │   │       ├── character_service.py
│   │   │   │       ├── conversation_service.py
│   │   │   │       ├── persona_service.py
│   │   │   │       └── proxy_service.py
│   │   │   ├── requirements.txt
│   │   │   └── run.py
│   │   ├── anime_server.py
│   │   ├── manga_server.py
│   │   └── novel_server/
│   │       ├── __pycache__/
│   │       │   ├── server.cpython-314.pyc
│   │       │   └── storage.cpython-314.pyc
│   │       ├── main.py
│   │       ├── providers/
│   │       │   ├── __init__.py
│   │       │   ├── __pycache__/
│   │       │   │   ├── __init__.cpython-314.pyc
│   │       │   │   ├── base.cpython-314.pyc
│   │       │   │   ├── freewebnovel.cpython-314.pyc
│   │       │   │   ├── novelbin.cpython-314.pyc
│   │       │   │   └── utils.cpython-314.pyc
│   │       │   ├── base.py
│   │       │   ├── freewebnovel.py
│   │       │   ├── novelbin.py
│   │       │   └── utils.py
│   │       ├── server.py
│   │       └── storage.py
│   ├── services/
│   │   ├── Anime.qml
│   │   ├── AppRegistry.qml
│   │   ├── Battery.qml
│   │   ├── Bluetooth.qml
│   │   ├── Cava.qml
│   │   ├── Github.qml
│   │   ├── Hyprland.qml
│   │   ├── LyricsService.qml
│   │   ├── Manga.qml
│   │   ├── Media.qml
│   │   ├── Network.qml
│   │   ├── Notes.qml
│   │   ├── Notification.qml
│   │   ├── Novel.qml
│   │   ├── OllamaService.qml
│   │   ├── Osd.qml
│   │   ├── System.qml
│   │   ├── Time.qml
│   │   ├── Volume.qml
│   │   └── Wallhaven.qml
│   ├── settings/
│   │   └── SettingsConfig.qml
│   ├── shell.qml
│   └── utils/
│       └── FileUtils.qml
├── rofi/
│   ├── colors.rasi
│   ├── config.rasi
│   ├── image-picker.rasi
│   ├── kaomoji.json
│   ├── kaomoji.txt
│   ├── modes/
│   │   ├── clipboard.sh
│   │   ├── emoji.sh
│   │   └── kaomoji.sh
│   ├── powermenu/
│   │   ├── powermenu.rasi
│   │   └── powermenu.sh
│   ├── scripts/
│   │   ├── brightness.sh
│   │   ├── clipboard.sh
│   │   ├── kaomoji-picker.sh
│   │   ├── volume.sh
│   │   └── wallpaper.sh
│   └── themes/
│       ├── hypr-matugen-dark.rasi
│       └── hypr-purple-metallic.rasi
└── scripts/
    ├── change-layout.sh
    ├── find-apps.sh
    ├── fix-discord-eio.sh
    └── smart-chrome.sh
```