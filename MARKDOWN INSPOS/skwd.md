```
skwd/
├── .github/
│   └── workflows/
│       └── aur-publish.yml
├── .gitignore
├── LICENSE
├── README.md
├── data/
│   ├── config.json.example
│   └── mdi-icons.json
├── flake.nix
├── packaging/
│   ├── aur/
│   │   ├── .SRCINFO
│   │   ├── PKGBUILD
│   │   └── skwd.install
│   ├── copr/
│   │   └── skwd.spec
│   └── wrappers/
│       ├── skwd-bar
│       ├── skwd-launch
│       ├── skwd-music
│       ├── skwd-notification
│       ├── skwd-power
│       ├── skwd-settings
│       └── skwd-switch
├── skwd-bar/
│   ├── data/
│   │   └── config.json.example
│   ├── ext/
│   │   └── cava/
│   │       └── cava-bar.conf
│   ├── qml/
│   │   ├── Colors.qml
│   │   ├── Config.qml
│   │   ├── bar/
│   │   │   ├── BarShell.qml
│   │   │   ├── TopBar.qml
│   │   │   ├── dropdowns/
│   │   │   │   ├── BluetoothDropdown.qml
│   │   │   │   ├── BrightnessDropdown.qml
│   │   │   │   ├── CalendarDropdown.qml
│   │   │   │   ├── DropdownTail.qml
│   │   │   │   ├── NotificationCenterDropdown.qml
│   │   │   │   ├── QsMemDropdown.qml
│   │   │   │   ├── VolumeDropdown.qml
│   │   │   │   ├── VolumeSlider.qml
│   │   │   │   ├── WeatherDropdown.qml
│   │   │   │   ├── WiFiDropdown.qml
│   │   │   │   └── qmldir
│   │   │   ├── lyrics/
│   │   │   │   ├── LyricsIsland.qml
│   │   │   │   ├── LyricsIslandService.qml
│   │   │   │   └── qmldir
│   │   │   └── qmldir
│   │   ├── qmldir
│   │   ├── services/
│   │   │   ├── DaemonClient.qml
│   │   │   ├── IpcService.qml
│   │   │   ├── LyricsService.qml
│   │   │   ├── SystemStatsService.qml
│   │   │   ├── WeatherService.qml
│   │   │   ├── WifiService.qml
│   │   │   ├── WmService.qml
│   │   │   └── qmldir
│   │   └── style.qml
│   └── shell.qml
├── skwd-launch/
│   ├── qml/
│   │   ├── Colors.qml
│   │   ├── Config.qml
│   │   ├── StyledToolTip.qml
│   │   ├── components/
│   │   │   ├── FilterButton.qml
│   │   │   ├── FilterDropdown.qml
│   │   │   ├── SettingsCombo.qml
│   │   │   ├── SettingsInput.qml
│   │   │   ├── SettingsSlider.qml
│   │   │   ├── SettingsTextInput.qml
│   │   │   └── SettingsToggle.qml
│   │   ├── launcher/
│   │   │   ├── AppLauncher.qml
│   │   │   ├── AppLauncherService.qml
│   │   │   ├── HexDelegate.qml
│   │   │   ├── LauncherShell.qml
│   │   │   ├── SliceDelegate.qml
│   │   │   └── qmldir
│   │   ├── qmldir
│   │   ├── services/
│   │   │   ├── AppCacheService.qml
│   │   │   └── qmldir
│   │   └── style.qml
│   └── shell.qml
├── skwd-music/
│   ├── data/
│   │   └── config.json.example
│   ├── qml/
│   │   ├── Colors.qml
│   │   ├── Config.qml
│   │   ├── components/
│   │   │   ├── AlbumArt.qml
│   │   │   ├── IconButton.qml
│   │   │   ├── ProgressBar.qml
│   │   │   └── qmldir
│   │   ├── player/
│   │   │   ├── ArtistSearchPanel.qml
│   │   │   ├── MusicPlayer.qml
│   │   │   ├── PlaylistPanel.qml
│   │   │   ├── PlaylistSearchPanel.qml
│   │   │   ├── PlaylistsPanel.qml
│   │   │   └── qmldir
│   │   ├── qmldir
│   │   ├── services/
│   │   │   ├── DaemonClient.qml
│   │   │   ├── LibrespotService.qml
│   │   │   ├── MprisService.qml
│   │   │   ├── SpotifyApi.qml
│   │   │   ├── SpotifyAuth.qml
│   │   │   └── qmldir
│   │   └── style.qml
│   └── shell.qml
├── skwd-notification/
│   ├── qml/
│   │   ├── Colors.qml
│   │   ├── Config.qml
│   │   ├── NotificationPopup.qml
│   │   ├── NotificationShell.qml
│   │   ├── Style.qml
│   │   └── qmldir
│   └── shell.qml
├── skwd-power/
│   ├── qml/
│   │   ├── Colors.qml
│   │   ├── Config.qml
│   │   ├── components/
│   │   │   ├── DimOverlay.qml
│   │   │   └── qmldir
│   │   ├── power/
│   │   │   ├── PowerMenu.qml
│   │   │   ├── PowerShell.qml
│   │   │   └── qmldir
│   │   ├── qmldir
│   │   ├── services/
│   │   │   ├── DaemonClient.qml
│   │   │   ├── WmService.qml
│   │   │   └── qmldir
│   │   └── style.qml
│   └── shell.qml
├── skwd-settings/
│   ├── qml/
│   │   ├── Colors.qml
│   │   ├── Config.qml
│   │   ├── SettingsShell.qml
│   │   ├── SettingsWindow.qml
│   │   ├── StyledToolTip.qml
│   │   ├── components/
│   │   │   ├── AppEditorRow.qml
│   │   │   ├── FilterButton.qml
│   │   │   ├── IconPicker.qml
│   │   │   ├── LauncherGridPreview.qml
│   │   │   ├── LauncherHexPreview.qml
│   │   │   ├── LauncherSlicePreview.qml
│   │   │   ├── RowAction.qml
│   │   │   ├── RowDropdown.qml
│   │   │   ├── RowInput.qml
│   │   │   ├── RowTextInput.qml
│   │   │   ├── RowToggle.qml
│   │   │   ├── SectionTitle.qml
│   │   │   ├── SettingsCard.qml
│   │   │   ├── SettingsDropdown.qml
│   │   │   ├── SettingsInput.qml
│   │   │   ├── SettingsRow.qml
│   │   │   ├── SettingsSlider.qml
│   │   │   ├── SettingsTextInput.qml
│   │   │   ├── SettingsToggle.qml
│   │   │   └── qmldir
│   │   ├── qmldir
│   │   ├── sections/
│   │   │   ├── BarSettings.qml
│   │   │   ├── GeneralSettings.qml
│   │   │   ├── LaunchSettings.qml
│   │   │   ├── ModulesSettings.qml
│   │   │   ├── MusicSettings.qml
│   │   │   ├── NotificationSettings.qml
│   │   │   ├── PlaceholderSection.qml
│   │   │   ├── PowerSettings.qml
│   │   │   ├── ProgramsSettings.qml
│   │   │   ├── SwitchSettings.qml
│   │   │   └── qmldir
│   │   ├── services/
│   │   │   ├── SettingsService.qml
│   │   │   └── qmldir
│   │   └── style.qml
│   └── shell.qml
└── skwd-switch/
    ├── qml/
    │   ├── Colors.qml
    │   ├── Config.qml
    │   ├── components/
    │   │   ├── DimOverlay.qml
    │   │   └── qmldir
    │   ├── qmldir
    │   ├── services/
    │   │   ├── IpcSwitchService.qml
    │   │   ├── WmService.qml
    │   │   └── qmldir
    │   ├── style.qml
    │   └── switcher/
    │       ├── SwitchShell.qml
    │       ├── WheelView.qml
    │       ├── WindowSwitcher.qml
    │       ├── WindowSwitcherService.qml
    │       └── qmldir
    └── shell.qml
```