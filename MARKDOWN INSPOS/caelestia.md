```
shell/
├── .clang-format
├── .envrc
├── .github/
│   ├── CONTRIBUTING.md
│   ├── FUNDING.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── config.yml
│   │   ├── crash.yml
│   │   ├── feature.yml
│   │   └── issue.yml
│   └── workflows/
│       ├── check-format.yml
│       ├── lint.yml
│       ├── release.yml
│       ├── update-flake-inputs.yml
│       └── update-image.yml
├── .gitignore
├── .vscode/
│   └── settings.json
├── CMakeLists.txt
├── LICENSE
├── README.md
├── assets/
│   ├── bongocat.gif
│   ├── dino.png
│   ├── kurukuru.gif
│   ├── logo.svg
│   ├── pam.d/
│   │   ├── fprint
│   │   └── passwd
│   ├── shaders/
│   │   ├── fade.frag
│   │   ├── fade.frag.qsb
│   │   ├── opacitymask.frag
│   │   └── opacitymask.frag.qsb
│   └── wrap_term_launch.sh
├── components/
│   ├── AnchorAnim.qml
│   ├── Anim.qml
│   ├── CAnim.qml
│   ├── ConnectionHeader.qml
│   ├── ConnectionInfoSection.qml
│   ├── DashboardState.qml
│   ├── DrawerVisibilities.qml
│   ├── Logo.qml
│   ├── MaterialIcon.qml
│   ├── PropertyRow.qml
│   ├── SectionContainer.qml
│   ├── SectionHeader.qml
│   ├── StateLayer.qml
│   ├── StyledClippingRect.qml
│   ├── StyledRect.qml
│   ├── StyledText.qml
│   ├── containers/
│   │   ├── StyledFlickable.qml
│   │   ├── StyledListView.qml
│   │   └── StyledWindow.qml
│   ├── controls/
│   │   ├── CircularIndicator.qml
│   │   ├── CircularProgress.qml
│   │   ├── CollapsibleSection.qml
│   │   ├── CustomMouseArea.qml
│   │   ├── CustomSpinBox.qml
│   │   ├── FilledSlider.qml
│   │   ├── IconButton.qml
│   │   ├── IconTextButton.qml
│   │   ├── Menu.qml
│   │   ├── MenuItem.qml
│   │   ├── SpinBoxRow.qml
│   │   ├── SplitButton.qml
│   │   ├── SplitButtonRow.qml
│   │   ├── StyledInputField.qml
│   │   ├── StyledRadioButton.qml
│   │   ├── StyledScrollBar.qml
│   │   ├── StyledSlider.qml
│   │   ├── StyledSwitch.qml
│   │   ├── StyledTextField.qml
│   │   ├── SwitchRow.qml
│   │   ├── TextButton.qml
│   │   ├── ToggleButton.qml
│   │   ├── ToggleRow.qml
│   │   └── Tooltip.qml
│   ├── effects/
│   │   ├── ColouredIcon.qml
│   │   ├── Colouriser.qml
│   │   ├── Elevation.qml
│   │   ├── InnerBorder.qml
│   │   └── OpacityMask.qml
│   ├── filedialog/
│   │   ├── CurrentItem.qml
│   │   ├── DialogButtons.qml
│   │   ├── FileDialog.qml
│   │   ├── FolderContents.qml
│   │   ├── HeaderBar.qml
│   │   ├── Sidebar.qml
│   │   └── Sizes.qml
│   ├── images/
│   │   ├── CachingIconImage.qml
│   │   └── CachingImage.qml
│   ├── misc/
│   │   ├── CustomShortcut.qml
│   │   └── Ref.qml
│   └── widgets/
│       └── ExtraIndicator.qml
├── extras/
│   ├── CMakeLists.txt
│   └── version.cpp
├── flake.lock
├── flake.nix
├── modules/
│   ├── BatteryMonitor.qml
│   ├── ConfigToasts.qml
│   ├── IdleMonitors.qml
│   ├── Shortcuts.qml
│   ├── areapicker/
│   │   ├── AreaPicker.qml
│   │   └── Picker.qml
│   ├── background/
│   │   ├── Background.qml
│   │   ├── DesktopClock.qml
│   │   ├── Visualiser.qml
│   │   └── Wallpaper.qml
│   ├── bar/
│   │   ├── Bar.qml
│   │   ├── BarWrapper.qml
│   │   ├── components/
│   │   │   ├── ActiveWindow.qml
│   │   │   ├── Clock.qml
│   │   │   ├── OsIcon.qml
│   │   │   ├── Power.qml
│   │   │   ├── StatusIcons.qml
│   │   │   ├── Tray.qml
│   │   │   ├── TrayItem.qml
│   │   │   └── workspaces/
│   │   │       ├── ActiveIndicator.qml
│   │   │       ├── OccupiedBg.qml
│   │   │       ├── SpecialWorkspaces.qml
│   │   │       ├── Workspace.qml
│   │   │       └── Workspaces.qml
│   │   └── popouts/
│   │       ├── ActiveWindow.qml
│   │       ├── Audio.qml
│   │       ├── Battery.qml
│   │       ├── Bluetooth.qml
│   │       ├── ClipWrapper.qml
│   │       ├── Content.qml
│   │       ├── LockStatus.qml
│   │       ├── Network.qml
│   │       ├── PopoutState.qml
│   │       ├── TrayMenu.qml
│   │       ├── WirelessPassword.qml
│   │       ├── Wrapper.qml
│   │       └── kblayout/
│   │           ├── KbLayout.qml
│   │           └── KbLayoutModel.qml
│   ├── controlcenter/
│   │   ├── ControlCenter.qml
│   │   ├── NavRail.qml
│   │   ├── PaneRegistry.qml
│   │   ├── Panes.qml
│   │   ├── Session.qml
│   │   ├── WindowFactory.qml
│   │   ├── WindowTitle.qml
│   │   ├── appearance/
│   │   │   ├── AppearancePane.qml
│   │   │   └── sections/
│   │   │       ├── AnimationsSection.qml
│   │   │       ├── BackgroundSection.qml
│   │   │       ├── BorderSection.qml
│   │   │       ├── ColorSchemeSection.qml
│   │   │       ├── ColorVariantSection.qml
│   │   │       ├── FontsSection.qml
│   │   │       ├── ScalesSection.qml
│   │   │       ├── ThemeModeSection.qml
│   │   │       └── TransparencySection.qml
│   │   ├── audio/
│   │   │   └── AudioPane.qml
│   │   ├── bluetooth/
│   │   │   ├── BtPane.qml
│   │   │   ├── Details.qml
│   │   │   ├── DeviceList.qml
│   │   │   └── Settings.qml
│   │   ├── components/
│   │   │   ├── ConnectedButtonGroup.qml
│   │   │   ├── DeviceDetails.qml
│   │   │   ├── DeviceList.qml
│   │   │   ├── PaneTransition.qml
│   │   │   ├── ReadonlySlider.qml
│   │   │   ├── SettingsHeader.qml
│   │   │   ├── SliderInput.qml
│   │   │   ├── SplitPaneLayout.qml
│   │   │   ├── SplitPaneWithDetails.qml
│   │   │   └── WallpaperGrid.qml
│   │   ├── dashboard/
│   │   │   ├── DashboardPane.qml
│   │   │   ├── GeneralSection.qml
│   │   │   └── PerformanceSection.qml
│   │   ├── launcher/
│   │   │   ├── LauncherPane.qml
│   │   │   └── Settings.qml
│   │   ├── network/
│   │   │   ├── EthernetDetails.qml
│   │   │   ├── EthernetList.qml
│   │   │   ├── EthernetPane.qml
│   │   │   ├── EthernetSettings.qml
│   │   │   ├── NetworkSettings.qml
│   │   │   ├── NetworkingPane.qml
│   │   │   ├── VpnDetails.qml
│   │   │   ├── VpnList.qml
│   │   │   ├── VpnSettings.qml
│   │   │   ├── WirelessDetails.qml
│   │   │   ├── WirelessList.qml
│   │   │   ├── WirelessPane.qml
│   │   │   ├── WirelessPasswordDialog.qml
│   │   │   └── WirelessSettings.qml
│   │   ├── notifications/
│   │   │   └── NotificationsPane.qml
│   │   ├── state/
│   │   │   ├── BluetoothState.qml
│   │   │   ├── EthernetState.qml
│   │   │   ├── LauncherState.qml
│   │   │   ├── NetworkState.qml
│   │   │   └── VpnState.qml
│   │   └── taskbar/
│   │       └── TaskbarPane.qml
│   ├── dashboard/
│   │   ├── Content.qml
│   │   ├── Dash.qml
│   │   ├── LyricMenu.qml
│   │   ├── LyricsView.qml
│   │   ├── Media.qml
│   │   ├── MediaWrapper.qml
│   │   ├── Performance.qml
│   │   ├── Tabs.qml
│   │   ├── WeatherTab.qml
│   │   ├── Wrapper.qml
│   │   └── dash/
│   │       ├── Calendar.qml
│   │       ├── DateTime.qml
│   │       ├── Media.qml
│   │       ├── Resources.qml
│   │       ├── SmallWeather.qml
│   │       └── User.qml
│   ├── drawers/
│   │   ├── ContentWindow.qml
│   │   ├── Drawers.qml
│   │   ├── Exclusions.qml
│   │   ├── Interactions.qml
│   │   ├── Panels.qml
│   │   └── Regions.qml
│   ├── launcher/
│   │   ├── AppList.qml
│   │   ├── Content.qml
│   │   ├── ContentList.qml
│   │   ├── WallpaperList.qml
│   │   ├── Wrapper.qml
│   │   ├── items/
│   │   │   ├── ActionItem.qml
│   │   │   ├── AppItem.qml
│   │   │   ├── CalcItem.qml
│   │   │   ├── SchemeItem.qml
│   │   │   ├── VariantItem.qml
│   │   │   └── WallpaperItem.qml
│   │   └── services/
│   │       ├── Actions.qml
│   │       ├── Apps.qml
│   │       ├── M3Variants.qml
│   │       └── Schemes.qml
│   ├── lock/
│   │   ├── Center.qml
│   │   ├── Content.qml
│   │   ├── Fetch.qml
│   │   ├── InputField.qml
│   │   ├── Lock.qml
│   │   ├── LockSurface.qml
│   │   ├── Media.qml
│   │   ├── NotifDock.qml
│   │   ├── NotifGroup.qml
│   │   ├── Pam.qml
│   │   ├── Resources.qml
│   │   └── WeatherInfo.qml
│   ├── notifications/
│   │   ├── Content.qml
│   │   ├── Notification.qml
│   │   └── Wrapper.qml
│   ├── osd/
│   │   ├── Content.qml
│   │   └── Wrapper.qml
│   ├── session/
│   │   ├── Content.qml
│   │   └── Wrapper.qml
│   ├── sidebar/
│   │   ├── Content.qml
│   │   ├── Notif.qml
│   │   ├── NotifActionList.qml
│   │   ├── NotifDock.qml
│   │   ├── NotifDockList.qml
│   │   ├── NotifGroup.qml
│   │   ├── NotifGroupList.qml
│   │   ├── Props.qml
│   │   └── Wrapper.qml
│   ├── utilities/
│   │   ├── Background.qml
│   │   ├── Content.qml
│   │   ├── RecordingDeleteModal.qml
│   │   ├── Wrapper.qml
│   │   ├── cards/
│   │   │   ├── IdleInhibit.qml
│   │   │   ├── Record.qml
│   │   │   ├── RecordingList.qml
│   │   │   └── Toggles.qml
│   │   └── toasts/
│   │       ├── ToastItem.qml
│   │       └── Toasts.qml
│   └── windowinfo/
│       ├── Buttons.qml
│       ├── Details.qml
│       ├── Preview.qml
│       └── WindowInfo.qml
├── nix/
│   ├── default.nix
│   └── hm-module.nix
├── plugin/
│   ├── CMakeLists.txt
│   └── src/
│       └── Caelestia/
│           ├── Blobs/
│           │   ├── CMakeLists.txt
│           │   ├── blobgroup.cpp
│           │   ├── blobgroup.hpp
│           │   ├── blobinvertedrect.cpp
│           │   ├── blobinvertedrect.hpp
│           │   ├── blobmaterial.cpp
│           │   ├── blobmaterial.hpp
│           │   ├── blobrect.cpp
│           │   ├── blobrect.hpp
│           │   ├── blobshape.cpp
│           │   ├── blobshape.hpp
│           │   └── shaders/
│           │       ├── blob.frag
│           │       └── blob.vert
│           ├── CMakeLists.txt
│           ├── Components/
│           │   ├── CMakeLists.txt
│           │   ├── lazylistview.cpp
│           │   └── lazylistview.hpp
│           ├── Config/
│           │   ├── CMakeLists.txt
│           │   ├── anim.cpp
│           │   ├── anim.hpp
│           │   ├── appearanceconfig.cpp
│           │   ├── appearanceconfig.hpp
│           │   ├── backgroundconfig.hpp
│           │   ├── barconfig.hpp
│           │   ├── borderconfig.hpp
│           │   ├── config.cpp
│           │   ├── config.hpp
│           │   ├── configattached.cpp
│           │   ├── configattached.hpp
│           │   ├── configobject.cpp
│           │   ├── configobject.hpp
│           │   ├── controlcenterconfig.hpp
│           │   ├── dashboardconfig.hpp
│           │   ├── generalconfig.hpp
│           │   ├── launcherconfig.hpp
│           │   ├── lockconfig.hpp
│           │   ├── monitorconfigmanager.cpp
│           │   ├── monitorconfigmanager.hpp
│           │   ├── notifsconfig.hpp
│           │   ├── osdconfig.hpp
│           │   ├── rootconfig.cpp
│           │   ├── rootconfig.hpp
│           │   ├── serviceconfig.hpp
│           │   ├── sessionconfig.hpp
│           │   ├── sidebarconfig.hpp
│           │   ├── tokens.cpp
│           │   ├── tokens.hpp
│           │   ├── tokensattached.cpp
│           │   ├── tokensattached.hpp
│           │   ├── userpaths.hpp
│           │   ├── utilitiesconfig.hpp
│           │   └── winfoconfig.hpp
│           ├── Images/
│           │   ├── CMakeLists.txt
│           │   ├── cachingimageprovider.cpp
│           │   ├── cachingimageprovider.hpp
│           │   ├── imagecacher.cpp
│           │   ├── imagecacher.hpp
│           │   ├── iutils.cpp
│           │   └── iutils.hpp
│           ├── Internal/
│           │   ├── CMakeLists.txt
│           │   ├── arcgauge.cpp
│           │   ├── arcgauge.hpp
│           │   ├── circularbuffer.cpp
│           │   ├── circularbuffer.hpp
│           │   ├── circularindicatormanager.cpp
│           │   ├── circularindicatormanager.hpp
│           │   ├── hyprdevices.cpp
│           │   ├── hyprdevices.hpp
│           │   ├── hyprextras.cpp
│           │   ├── hyprextras.hpp
│           │   ├── logindmanager.cpp
│           │   ├── logindmanager.hpp
│           │   ├── sparklineitem.cpp
│           │   ├── sparklineitem.hpp
│           │   ├── visualiserbars.cpp
│           │   └── visualiserbars.hpp
│           ├── Models/
│           │   ├── CMakeLists.txt
│           │   ├── filesystemmodel.cpp
│           │   └── filesystemmodel.hpp
│           ├── Services/
│           │   ├── CMakeLists.txt
│           │   ├── audiocollector.cpp
│           │   ├── audiocollector.hpp
│           │   ├── audioprovider.cpp
│           │   ├── audioprovider.hpp
│           │   ├── beattracker.cpp
│           │   ├── beattracker.hpp
│           │   ├── cavaprovider.cpp
│           │   ├── cavaprovider.hpp
│           │   ├── service.cpp
│           │   ├── service.hpp
│           │   ├── serviceref.cpp
│           │   └── serviceref.hpp
│           ├── appdb.cpp
│           ├── appdb.hpp
│           ├── cutils.cpp
│           ├── cutils.hpp
│           ├── imageanalyser.cpp
│           ├── imageanalyser.hpp
│           ├── qalculator.cpp
│           ├── qalculator.hpp
│           ├── requests.cpp
│           ├── requests.hpp
│           ├── toaster.cpp
│           └── toaster.hpp
├── scripts/
│   └── qml-lint-conventions.py
├── services/
│   ├── Audio.qml
│   ├── Brightness.qml
│   ├── Colours.qml
│   ├── GameMode.qml
│   ├── Hypr.qml
│   ├── IdleInhibitor.qml
│   ├── LyricsService.qml
│   ├── Network.qml
│   ├── NetworkUsage.qml
│   ├── Nmcli.qml
│   ├── NotifData.qml
│   ├── Notifs.qml
│   ├── Players.qml
│   ├── Recorder.qml
│   ├── Screens.qml
│   ├── SystemUsage.qml
│   ├── Time.qml
│   ├── VPN.qml
│   ├── Visibilities.qml
│   ├── Wallpapers.qml
│   └── Weather.qml
├── shell.qml
└── utils/
    ├── Icons.qml
    ├── Images.qml
    ├── NetworkConnection.qml
    ├── Paths.qml
    ├── Searcher.qml
    ├── Strings.qml
    ├── SysInfo.qml
    └── scripts/
        ├── fuzzysort.js
        ├── fzf.js
        └── lrcparser.js
```