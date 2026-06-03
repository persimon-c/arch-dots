```
dots-hyprland/
├── .github/
│   ├── CONTRIBUTING.md
│   ├── FUNDING.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── 1-issue.yml
│   │   ├── 2-feature_request.yml
│   │   └── config.yml
│   ├── README.md
│   ├── assets/
│   │   └── illogical-impulse.svg
│   ├── pull_request_template.md
│   └── workflows/
│       ├── auto-close-issue.yml
│       ├── dist-update-notification.yml
│       ├── dump-github-context.yml
│       └── moderator.yml
├── .gitignore
├── .gitmodules
├── LICENSE
├── diagnose
├── dots-extra/
│   ├── emacs/
│   │   └── material-theme.el
│   ├── fcitx5/
│   │   └── conf/
│   │       └── classicui.conf
│   ├── fedora/
│   │   └── hypr/
│   │       └── hyprland/
│   │           └── execs.conf
│   ├── fontsets/
│   │   └── ar/
│   │       └── fonts.conf
│   ├── swaylock/
│   │   └── config
│   └── via-nix/
│       ├── README.md
│       └── hypridle.conf
├── dots/
│   ├── .config/
│   │   ├── Kvantum/
│   │   │   ├── Colloid/
│   │   │   │   ├── Colloid.kvconfig
│   │   │   │   ├── Colloid.svg
│   │   │   │   ├── ColloidDark.kvconfig
│   │   │   │   └── ColloidDark.svg
│   │   │   ├── MaterialAdw/
│   │   │   │   ├── MaterialAdw.kvconfig
│   │   │   │   └── MaterialAdw.svg
│   │   │   └── kvantum.kvconfig
│   │   ├── chrome-flags.conf
│   │   ├── code-flags.conf
│   │   ├── darklyrc
│   │   ├── dolphinrc
│   │   ├── fish/
│   │   │   ├── auto-Hypr.fish
│   │   │   ├── config.fish
│   │   │   └── fish_variables
│   │   ├── fontconfig/
│   │   │   └── fonts.conf
│   │   ├── foot/
│   │   │   └── foot.ini
│   │   ├── fuzzel/
│   │   │   ├── fuzzel.ini
│   │   │   └── fuzzel_theme.ini
│   │   ├── hypr/
│   │   │   ├── custom/
│   │   │   │   ├── env.lua
│   │   │   │   ├── execs.lua
│   │   │   │   ├── general.lua
│   │   │   │   ├── keybinds.lua
│   │   │   │   ├── rules.lua
│   │   │   │   ├── scripts/
│   │   │   │   │   └── __restore_video_wallpaper.sh
│   │   │   │   └── variables.lua
│   │   │   ├── hypridle.conf
│   │   │   ├── hyprland.lua
│   │   │   ├── hyprland/
│   │   │   │   ├── colors.lua
│   │   │   │   ├── env.lua
│   │   │   │   ├── execs.lua
│   │   │   │   ├── general.lua
│   │   │   │   ├── keybinds.lua
│   │   │   │   ├── lib/
│   │   │   │   │   └── init.lua
│   │   │   │   ├── rules.lua
│   │   │   │   ├── scripts/
│   │   │   │   │   ├── ai/
│   │   │   │   │   │   ├── license_show-loaded-ollama-models.txt
│   │   │   │   │   │   ├── primary-buffer-query.sh
│   │   │   │   │   │   └── show-loaded-ollama-models.sh
│   │   │   │   │   ├── fuzzel-emoji.sh
│   │   │   │   │   ├── launch_first_available.sh
│   │   │   │   │   ├── snip_to_search.sh
│   │   │   │   │   └── start_geoclue_agent.sh
│   │   │   │   ├── services/
│   │   │   │   │   ├── create_custom_config.lua
│   │   │   │   │   └── init.lua
│   │   │   │   ├── shellOverrides/
│   │   │   │   │   └── main.lua
│   │   │   │   └── variables.lua
│   │   │   ├── hyprlock.conf
│   │   │   └── hyprlock/
│   │   │       ├── check-capslock.sh
│   │   │       ├── colors.conf
│   │   │       └── status.sh
│   │   ├── kde-material-you-colors/
│   │   │   └── config.conf
│   │   ├── kdeglobals
│   │   ├── kitty/
│   │   │   ├── kitty.conf
│   │   │   ├── scroll_mark.py
│   │   │   └── search.py
│   │   ├── konsolerc
│   │   ├── matugen/
│   │   │   ├── config.toml
│   │   │   └── templates/
│   │   │       ├── ags/
│   │   │       │   ├── _material.scss
│   │   │       │   ├── sourceviewtheme-light.xml
│   │   │       │   └── sourceviewtheme.xml
│   │   │       ├── colors.json
│   │   │       ├── fuzzel/
│   │   │       │   └── fuzzel_theme.ini
│   │   │       ├── gtk-3.0/
│   │   │       │   └── gtk.css
│   │   │       ├── gtk-4.0/
│   │   │       │   └── gtk.css
│   │   │       ├── hyprland/
│   │   │       │   ├── colors.lua
│   │   │       │   └── hyprlock-colors.conf
│   │   │       ├── kde/
│   │   │       │   ├── color.txt
│   │   │       │   └── kde-material-you-colors-wrapper.sh
│   │   │       └── wallpaper.txt
│   │   ├── mpv/
│   │   │   └── mpv.conf
│   │   ├── quickshell/
│   │   │   └── ii/
│   │   │       ├── .qmlformat.ini
│   │   │       ├── GlobalStates.qml
│   │   │       ├── ReloadPopup.qml
│   │   │       ├── assets/
│   │   │       │   ├── icons/
│   │   │       │   │   ├── fluent/
│   │   │       │   └── images/
│   │   │       ├── defaults/
│   │   │       │   └── ai/
│   │   │       │       ├── README.md
│   │   │       │       └── prompts/
│   │   │       │           ├── NoPrompt.md
│   │   │       │           ├── ii-Default.md
│   │   │       │           ├── ii-Imouto.md
│   │   │       │           ├── nyarch-Acchan.md
│   │   │       │           ├── w-FourPointedSparkle.md
│   │   │       │           └── w-OpenMechanicalFlower.md
│   │   │       ├── killDialog.qml
│   │   │       ├── modules/
│   │   │       │   ├── common/
│   │   │       │   │   ├── Appearance.qml
│   │   │       │   │   ├── Config.qml
│   │   │       │   │   ├── Directories.qml
│   │   │       │   │   ├── Icons.qml
│   │   │       │   │   ├── Images.qml
│   │   │       │   │   ├── Persistent.qml
│   │   │       │   │   ├── functions/
│   │   │       │   │   │   ├── ColorUtils.qml
│   │   │       │   │   │   ├── DateUtils.qml
│   │   │       │   │   │   ├── FileUtils.qml
│   │   │       │   │   │   ├── Fuzzy.qml
│   │   │       │   │   │   ├── Levendist.qml
│   │   │       │   │   │   ├── NotificationUtils.qml
│   │   │       │   │   │   ├── ObjectUtils.qml
│   │   │       │   │   │   ├── Session.qml
│   │   │       │   │   │   ├── StringUtils.qml
│   │   │       │   │   │   ├── fuzzysort.js
│   │   │       │   │   │   └── levendist.js
│   │   │       │   │   ├── models/
│   │   │       │   │   │   ├── AdaptedMaterialScheme.qml
│   │   │       │   │   │   ├── AnimatedTabIndexPair.qml
│   │   │       │   │   │   ├── FolderListModelWithHistory.qml
│   │   │       │   │   │   ├── IndexModel.qml
│   │   │       │   │   │   ├── LauncherSearchResult.qml
│   │   │       │   │   │   ├── NestableObject.qml
│   │   │       │   │   │   ├── gCloud/
│   │   │       │   │   │   │   ├── GCloudApi.qml
│   │   │       │   │   │   │   ├── GCloudTranslate.qml
│   │   │       │   │   │   │   ├── GCloudVision.qml
│   │   │       │   │   │   │   └── GCloudVisionResult.qml
│   │   │       │   │   │   ├── hyprland/
│   │   │       │   │   │   │   └── HyprlandConfigOption.qml
│   │   │       │   │   │   └── quickToggles/
│   │   │       │   │   │       ├── AntiFlashbangToggle.qml
│   │   │       │   │   │       ├── AudioToggle.qml
│   │   │       │   │   │       ├── BluetoothToggle.qml
│   │   │       │   │   │       ├── CloudflareWarpToggle.qml
│   │   │       │   │   │       ├── ColorPickerToggle.qml
│   │   │       │   │   │       ├── DarkModeToggle.qml
│   │   │       │   │   │       ├── EasyEffectsToggle.qml
│   │   │       │   │   │       ├── GameModeToggle.qml
│   │   │       │   │   │       ├── IdleInhibitorToggle.qml
│   │   │       │   │   │       ├── MicToggle.qml
│   │   │       │   │   │       ├── MusicRecognitionToggle.qml
│   │   │       │   │   │       ├── NetworkToggle.qml
│   │   │       │   │   │       ├── NightLightToggle.qml
│   │   │       │   │   │       ├── NotificationToggle.qml
│   │   │       │   │   │       ├── OnScreenKeyboardToggle.qml
│   │   │       │   │   │       ├── PowerProfilesToggle.qml
│   │   │       │   │   │       ├── QuickToggleModel.qml
│   │   │       │   │   │       └── ScreenSnipToggle.qml
│   │   │       │   │   ├── panels/
│   │   │       │   │   │   └── lock/
│   │   │       │   │   │       ├── LockContext.qml
│   │   │       │   │   │       ├── LockScreen.qml
│   │   │       │   │   │       └── pam/
│   │   │       │   │   │           └── fprintd.conf
│   │   │       │   │   ├── utils/
│   │   │       │   │   │   ├── ImageDownloaderProcess.qml
│   │   │       │   │   │   ├── MultiTurnProcess.qml
│   │   │       │   │   │   ├── ScreenshotAction.qml
│   │   │       │   │   │   └── TempScreenshotProcess.qml
│   │   │       │   │   └── widgets/
│   │   │       │   │       ├── AddressBar.qml
│   │   │       │   │       ├── AddressBreadcrumb.qml
│   │   │       │   │       ├── ButtonGroup.qml
│   │   │       │   │       ├── CalendarView.qml
│   │   │       │   │       ├── Circle.qml
│   │   │       │   │       ├── CircularProgress.qml
│   │   │       │   │       ├── CliphistImage.qml
│   │   │       │   │       ├── ClippedFilledCircularProgress.qml
│   │   │       │   │       ├── ClippedProgressBar.qml
│   │   │       │   │       ├── ConfigRow.qml
│   │   │       │   │       ├── ConfigSelectionArray.qml
│   │   │       │   │       ├── ConfigSlider.qml
│   │   │       │   │       ├── ConfigSpinBox.qml
│   │   │       │   │       ├── ConfigSwitch.qml
│   │   │       │   │       ├── ContentPage.qml
│   │   │       │   │       ├── ContentSection.qml
│   │   │       │   │       ├── ContentSubsection.qml
│   │   │       │   │       ├── ContentSubsectionLabel.qml
│   │   │       │   │       ├── CustomIcon.qml
│   │   │       │   │       ├── DashedBorder.qml
│   │   │       │   │       ├── DialogButton.qml
│   │   │       │   │       ├── DialogListItem.qml
│   │   │       │   │       ├── DirectoryIcon.qml
│   │   │       │   │       ├── DragManager.qml
│   │   │       │   │       ├── ErrorShakeAnimation.qml
│   │   │       │   │       ├── FadeLoader.qml
│   │   │       │   │       ├── Favicon.qml
│   │   │       │   │       ├── FloatingActionButton.qml
│   │   │       │   │       ├── FlowButtonGroup.qml
│   │   │       │   │       ├── FocusedScrollMouseArea.qml
│   │   │       │   │       ├── FullscreenPolkitWindow.qml
│   │   │       │   │       ├── Graph.qml
│   │   │       │   │       ├── GroupButton.qml
│   │   │       │   │       ├── IconAndTextToolbarButton.qml
│   │   │       │   │       ├── IconToolbarButton.qml
│   │   │       │   │       ├── KeyboardKey.qml
│   │   │       │   │       ├── LightDarkPreferenceButton.qml
│   │   │       │   │       ├── MaskMultiEffect.qml
│   │   │       │   │       ├── MaterialCookie.qml
│   │   │       │   │       ├── MaterialLoadingIndicator.qml
│   │   │       │   │       ├── MaterialShape.qml
│   │   │       │   │       ├── MaterialShapeWrappedMaterialSymbol.qml
│   │   │       │   │       ├── MaterialSymbol.qml
│   │   │       │   │       ├── MaterialTextArea.qml
│   │   │       │   │       ├── MaterialTextField.qml
│   │   │       │   │       ├── MenuButton.qml
│   │   │       │   │       ├── NavigationRail.qml
│   │   │       │   │       ├── NavigationRailButton.qml
│   │   │       │   │       ├── NavigationRailExpandButton.qml
│   │   │       │   │       ├── NavigationRailTabArray.qml
│   │   │       │   │       ├── NoticeBox.qml
│   │   │       │   │       ├── NotificationActionButton.qml
│   │   │       │   │       ├── NotificationAppIcon.qml
│   │   │       │   │       ├── NotificationGroup.qml
│   │   │       │   │       ├── NotificationGroupExpandButton.qml
│   │   │       │   │       ├── NotificationItem.qml
│   │   │       │   │       ├── NotificationListView.qml
│   │   │       │   │       ├── OptionalMaterialSymbol.qml
│   │   │       │   │       ├── PagePlaceholder.qml
│   │   │       │   │       ├── PointingHandInteraction.qml
│   │   │       │   │       ├── PointingHandLinkHover.qml
│   │   │       │   │       ├── PopupToolTip.qml
│   │   │       │   │       ├── Revealer.qml
│   │   │       │   │       ├── RippleButton.qml
│   │   │       │   │       ├── RippleButtonWithIcon.qml
│   │   │       │   │       ├── RoundCorner.qml
│   │   │       │   │       ├── ScrollEdgeFade.qml
│   │   │       │   │       ├── SecondaryTabBar.qml
│   │   │       │   │       ├── SecondaryTabButton.qml
│   │   │       │   │       ├── SelectionDialog.qml
│   │   │       │   │       ├── SelectionGroupButton.qml
│   │   │       │   │       ├── SineCookie.qml
│   │   │       │   │       ├── SqueezedAnnotationStyledText.qml
│   │   │       │   │       ├── StyledBlurEffect.qml
│   │   │       │   │       ├── StyledComboBox.qml
│   │   │       │   │       ├── StyledDropShadow.qml
│   │   │       │   │       ├── StyledFlickable.qml
│   │   │       │   │       ├── StyledImage.qml
│   │   │       │   │       ├── StyledIndeterminateProgressBar.qml
│   │   │       │   │       ├── StyledListView.qml
│   │   │       │   │       ├── StyledProgressBar.qml
│   │   │       │   │       ├── StyledRadioButton.qml
│   │   │       │   │       ├── StyledRectangularShadow.qml
│   │   │       │   │       ├── StyledScrollBar.qml
│   │   │       │   │       ├── StyledSlider.qml
│   │   │       │   │       ├── StyledSpinBox.qml
│   │   │       │   │       ├── StyledSwitch.qml
│   │   │       │   │       ├── StyledText.qml
│   │   │       │   │       ├── StyledTextArea.qml
│   │   │       │   │       ├── StyledTextInput.qml
│   │   │       │   │       ├── StyledToolTip.qml
│   │   │       │   │       ├── StyledToolTipContent.qml
│   │   │       │   │       ├── ThumbnailImage.qml
│   │   │       │   │       ├── Toolbar.qml
│   │   │       │   │       ├── ToolbarButton.qml
│   │   │       │   │       ├── ToolbarPairedFab.qml
│   │   │       │   │       ├── ToolbarTabBar.qml
│   │   │       │   │       ├── ToolbarTabButton.qml
│   │   │       │   │       ├── ToolbarTextField.qml
│   │   │       │   │       ├── VerticalButtonGroup.qml
│   │   │       │   │       ├── VibrantToolbarButton.qml
│   │   │       │   │       ├── WaveVisualizer.qml
│   │   │       │   │       ├── WavyLine.qml
│   │   │       │   │       ├── WeekRow.qml
│   │   │       │   │       ├── WindowDialog.qml
│   │   │       │   │       ├── WindowDialogButtonRow.qml
│   │   │       │   │       ├── WindowDialogParagraph.qml
│   │   │       │   │       ├── WindowDialogSectionHeader.qml
│   │   │       │   │       ├── WindowDialogSeparator.qml
│   │   │       │   │       ├── WindowDialogSlider.qml
│   │   │       │   │       ├── WindowDialogTitle.qml
│   │   │       │   │       ├── shapes/
│   │   │       │   │       └── widgetCanvas/
│   │   │       │   │           ├── AbstractOverlayWidget.qml
│   │   │       │   │           ├── AbstractWidget.qml
│   │   │       │   │           └── WidgetCanvas.qml
│   │   │       │   ├── ii/
│   │   │       │   │   ├── background/
│   │   │       │   │   │   ├── Background.qml
│   │   │       │   │   │   └── widgets/
│   │   │       │   │   │       ├── AbstractBackgroundWidget.qml
│   │   │       │   │   │       ├── clock/
│   │   │       │   │   │       │   ├── ClockText.qml
│   │   │       │   │   │       │   ├── ClockWidget.qml
│   │   │       │   │   │       │   ├── CookieClock.qml
│   │   │       │   │   │       │   ├── CookieQuote.qml
│   │   │       │   │   │       │   ├── DigitalClock.qml
│   │   │       │   │   │       │   ├── HourHand.qml
│   │   │       │   │   │       │   ├── HourMarks.qml
│   │   │       │   │   │       │   ├── MinuteHand.qml
│   │   │       │   │   │       │   ├── SecondHand.qml
│   │   │       │   │   │       │   ├── TimeColumn.qml
│   │   │       │   │   │       │   ├── dateIndicator/
│   │   │       │   │   │       │   │   ├── BubbleDate.qml
│   │   │       │   │   │       │   │   ├── DateIndicator.qml
│   │   │       │   │   │       │   │   ├── RectangleDate.qml
│   │   │       │   │   │       │   │   └── RotatingDate.qml
│   │   │       │   │   │       │   └── minuteMarks/
│   │   │       │   │   │       │       ├── BigHourNumbers.qml
│   │   │       │   │   │       │       ├── Dots.qml
│   │   │       │   │   │       │       ├── Lines.qml
│   │   │       │   │   │       │       └── MinuteMarks.qml
│   │   │       │   │   │       └── weather/
│   │   │       │   │   │           └── WeatherWidget.qml
│   │   │       │   │   ├── bar/
│   │   │       │   │   │   ├── ActiveWindow.qml
│   │   │       │   │   │   ├── Bar.qml
│   │   │       │   │   │   ├── BarContent.qml
│   │   │       │   │   │   ├── BarGroup.qml
│   │   │       │   │   │   ├── BatteryIndicator.qml
│   │   │       │   │   │   ├── BatteryPopup.qml
│   │   │       │   │   │   ├── CircleUtilButton.qml
│   │   │       │   │   │   ├── ClockWidget.qml
│   │   │       │   │   │   ├── ClockWidgetPopup.qml
│   │   │       │   │   │   ├── HyprlandXkbIndicator.qml
│   │   │       │   │   │   ├── LeftSidebarButton.qml
│   │   │       │   │   │   ├── Media.qml
│   │   │       │   │   │   ├── NotificationUnreadCount.qml
│   │   │       │   │   │   ├── Resource.qml
│   │   │       │   │   │   ├── Resources.qml
│   │   │       │   │   │   ├── ResourcesPopup.qml
│   │   │       │   │   │   ├── ScrollHint.qml
│   │   │       │   │   │   ├── StyledPopup.qml
│   │   │       │   │   │   ├── StyledPopupHeaderRow.qml
│   │   │       │   │   │   ├── StyledPopupValueRow.qml
│   │   │       │   │   │   ├── SysTray.qml
│   │   │       │   │   │   ├── SysTrayItem.qml
│   │   │       │   │   │   ├── SysTrayMenu.qml
│   │   │       │   │   │   ├── SysTrayMenuEntry.qml
│   │   │       │   │   │   ├── UtilButtons.qml
│   │   │       │   │   │   ├── Workspaces.qml
│   │   │       │   │   │   └── weather/
│   │   │       │   │   │       ├── WeatherBar.qml
│   │   │       │   │   │       ├── WeatherCard.qml
│   │   │       │   │   │       └── WeatherPopup.qml
│   │   │       │   │   ├── cheatsheet/
│   │   │       │   │   │   ├── Cheatsheet.qml
│   │   │       │   │   │   ├── CheatsheetKeybinds.qml
│   │   │       │   │   │   ├── CheatsheetKeybindsCategory.qml
│   │   │       │   │   │   ├── CheatsheetPeriodicTable.qml
│   │   │       │   │   │   ├── ElementTile.qml
│   │   │       │   │   │   └── periodic_table.js
│   │   │       │   │   ├── dock/
│   │   │       │   │   │   ├── Dock.qml
│   │   │       │   │   │   ├── DockAppButton.qml
│   │   │       │   │   │   ├── DockApps.qml
│   │   │       │   │   │   ├── DockButton.qml
│   │   │       │   │   │   └── DockSeparator.qml
│   │   │       │   │   ├── lock/
│   │   │       │   │   │   ├── Lock.qml
│   │   │       │   │   │   ├── LockSurface.qml
│   │   │       │   │   │   └── PasswordChars.qml
│   │   │       │   │   ├── mediaControls/
│   │   │       │   │   │   ├── MediaControls.qml
│   │   │       │   │   │   └── PlayerControl.qml
│   │   │       │   │   ├── notificationPopup/
│   │   │       │   │   │   └── NotificationPopup.qml
│   │   │       │   │   ├── onScreenDisplay/
│   │   │       │   │   │   ├── OnScreenDisplay.qml
│   │   │       │   │   │   ├── OsdValueIndicator.qml
│   │   │       │   │   │   └── indicators/
│   │   │       │   │   │       ├── BrightnessIndicator.qml
│   │   │       │   │   │       ├── GammaIndicator.qml
│   │   │       │   │   │       └── VolumeIndicator.qml
│   │   │       │   │   ├── onScreenKeyboard/
│   │   │       │   │   │   ├── OnScreenKeyboard.qml
│   │   │       │   │   │   ├── OskContent.qml
│   │   │       │   │   │   ├── OskKey.qml
│   │   │       │   │   │   └── layouts.js
│   │   │       │   │   ├── overlay/
│   │   │       │   │   │   ├── Overlay.qml
│   │   │       │   │   │   ├── OverlayBackground.qml
│   │   │       │   │   │   ├── OverlayContent.qml
│   │   │       │   │   │   ├── OverlayContext.qml
│   │   │       │   │   │   ├── OverlayTaskbar.qml
│   │   │       │   │   │   ├── OverlayWidgetDelegateChooser.qml
│   │   │       │   │   │   ├── StyledOverlayWidget.qml
│   │   │       │   │   │   ├── crosshair/
│   │   │       │   │   │   │   ├── Crosshair.qml
│   │   │       │   │   │   │   └── CrosshairContent.qml
│   │   │       │   │   │   ├── floatingImage/
│   │   │       │   │   │   │   └── FloatingImage.qml
│   │   │       │   │   │   ├── fpsLimiter/
│   │   │       │   │   │   │   ├── FpsLimiter.qml
│   │   │       │   │   │   │   └── FpsLimiterContent.qml
│   │   │       │   │   │   ├── notes/
│   │   │       │   │   │   │   ├── Notes.qml
│   │   │       │   │   │   │   └── NotesContent.qml
│   │   │       │   │   │   ├── recorder/
│   │   │       │   │   │   │   └── Recorder.qml
│   │   │       │   │   │   ├── resources/
│   │   │       │   │   │   │   └── Resources.qml
│   │   │       │   │   │   └── volumeMixer/
│   │   │       │   │   │       └── VolumeMixer.qml
│   │   │       │   │   ├── overview/
│   │   │       │   │   │   ├── Overview.qml
│   │   │       │   │   │   ├── OverviewWidget.qml
│   │   │       │   │   │   ├── OverviewWindow.qml
│   │   │       │   │   │   ├── SearchBar.qml
│   │   │       │   │   │   ├── SearchItem.qml
│   │   │       │   │   │   └── SearchWidget.qml
│   │   │       │   │   ├── polkit/
│   │   │       │   │   │   ├── Polkit.qml
│   │   │       │   │   │   └── PolkitContent.qml
│   │   │       │   │   ├── regionSelector/
│   │   │       │   │   │   ├── CircleSelectionDetails.qml
│   │   │       │   │   │   ├── CursorGuide.qml
│   │   │       │   │   │   ├── OptionsToolbar.qml
│   │   │       │   │   │   ├── RectCornersSelectionDetails.qml
│   │   │       │   │   │   ├── RegionFunctions.qml
│   │   │       │   │   │   ├── RegionSelection.qml
│   │   │       │   │   │   ├── RegionSelector.qml
│   │   │       │   │   │   └── TargetRegion.qml
│   │   │       │   │   ├── screenCorners/
│   │   │       │   │   │   └── ScreenCorners.qml
│   │   │       │   │   ├── screenTranslator/
│   │   │       │   │   │   ├── ScreenTextOverlay.qml
│   │   │       │   │   │   ├── ScreenTranslator.qml
│   │   │       │   │   │   └── ScreenTranslatorPanel.qml
│   │   │       │   │   ├── sessionScreen/
│   │   │       │   │   │   ├── SessionActionButton.qml
│   │   │       │   │   │   └── SessionScreen.qml
│   │   │       │   │   ├── sidebarLeft/
│   │   │       │   │   │   ├── AiChat.qml
│   │   │       │   │   │   ├── Anime.qml
│   │   │       │   │   │   ├── ApiCommandButton.qml
│   │   │       │   │   │   ├── ApiInputBoxIndicator.qml
│   │   │       │   │   │   ├── DescriptionBox.qml
│   │   │       │   │   │   ├── ScrollToBottomButton.qml
│   │   │       │   │   │   ├── SidebarLeft.qml
│   │   │       │   │   │   ├── SidebarLeftContent.qml
│   │   │       │   │   │   ├── Translator.qml
│   │   │       │   │   │   ├── aiChat/
│   │   │       │   │   │   │   ├── AiMessage.qml
│   │   │       │   │   │   │   ├── AiMessageControlButton.qml
│   │   │       │   │   │   │   ├── AnnotationSourceButton.qml
│   │   │       │   │   │   │   ├── AttachedFileIndicator.qml
│   │   │       │   │   │   │   ├── MessageCodeBlock.qml
│   │   │       │   │   │   │   ├── MessageTextBlock.qml
│   │   │       │   │   │   │   ├── MessageThinkBlock.qml
│   │   │       │   │   │   │   └── SearchQueryButton.qml
│   │   │       │   │   │   ├── anime/
│   │   │       │   │   │   │   ├── BooruImage.qml
│   │   │       │   │   │   │   └── BooruResponse.qml
│   │   │       │   │   │   └── translator/
│   │   │       │   │   │       ├── LanguageSelectorButton.qml
│   │   │       │   │   │       └── TextCanvas.qml
│   │   │       │   │   ├── sidebarRight/
│   │   │       │   │   │   ├── BottomWidgetGroup.qml
│   │   │       │   │   │   ├── CenterWidgetGroup.qml
│   │   │       │   │   │   ├── QuickSliders.qml
│   │   │       │   │   │   ├── SidebarRight.qml
│   │   │       │   │   │   ├── SidebarRightContent.qml
│   │   │       │   │   │   ├── bluetoothDevices/
│   │   │       │   │   │   │   ├── BluetoothDeviceItem.qml
│   │   │       │   │   │   │   └── BluetoothDialog.qml
│   │   │       │   │   │   ├── calendar/
│   │   │       │   │   │   │   ├── CalendarDayButton.qml
│   │   │       │   │   │   │   ├── CalendarHeaderButton.qml
│   │   │       │   │   │   │   ├── CalendarWidget.qml
│   │   │       │   │   │   │   └── calendar_layout.js
│   │   │       │   │   │   ├── nightLight/
│   │   │       │   │   │   │   └── NightLightDialog.qml
│   │   │       │   │   │   ├── notifications/
│   │   │       │   │   │   │   ├── NotificationList.qml
│   │   │       │   │   │   │   └── NotificationStatusButton.qml
│   │   │       │   │   │   ├── pomodoro/
│   │   │       │   │   │   │   ├── PomodoroTimer.qml
│   │   │       │   │   │   │   ├── PomodoroWidget.qml
│   │   │       │   │   │   │   └── Stopwatch.qml
│   │   │       │   │   │   ├── quickToggles/
│   │   │       │   │   │   │   ├── AbstractQuickPanel.qml
│   │   │       │   │   │   │   ├── AndroidQuickPanel.qml
│   │   │       │   │   │   │   ├── ClassicQuickPanel.qml
│   │   │       │   │   │   │   ├── androidStyle/
│   │   │       │   │   │   │   │   ├── AndroidAntiFlashbangToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidAudioToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidBluetoothToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidCloudflareWarpToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidColorPickerToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidDarkModeToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidEasyEffectsToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidGameModeToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidIdleInhibitorToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidMicToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidMusicRecognition.qml
│   │   │       │   │   │   │   │   ├── AndroidNetworkToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidNightLightToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidNotificationToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidOnScreenKeyboardToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidPowerProfileToggle.qml
│   │   │       │   │   │   │   │   ├── AndroidQuickToggleButton.qml
│   │   │       │   │   │   │   │   ├── AndroidScreenSnipToggle.qml
│   │   │       │   │   │   │   │   └── AndroidToggleDelegateChooser.qml
│   │   │       │   │   │   │   └── classicStyle/
│   │   │       │   │   │   │       ├── BluetoothToggle.qml
│   │   │       │   │   │   │       ├── CloudflareWarp.qml
│   │   │       │   │   │   │       ├── EasyEffectsToggle.qml
│   │   │       │   │   │   │       ├── GameMode.qml
│   │   │       │   │   │   │       ├── IdleInhibitor.qml
│   │   │       │   │   │   │       ├── NetworkToggle.qml
│   │   │       │   │   │   │       ├── NightLight.qml
│   │   │       │   │   │   │       └── QuickToggleButton.qml
│   │   │       │   │   │   ├── todo/
│   │   │       │   │   │   │   ├── TaskList.qml
│   │   │       │   │   │   │   ├── TodoItemActionButton.qml
│   │   │       │   │   │   │   └── TodoWidget.qml
│   │   │       │   │   │   ├── volumeMixer/
│   │   │       │   │   │   │   ├── AudioDeviceSelectorButton.qml
│   │   │       │   │   │   │   ├── VolumeDialog.qml
│   │   │       │   │   │   │   ├── VolumeDialogContent.qml
│   │   │       │   │   │   │   └── VolumeMixerEntry.qml
│   │   │       │   │   │   └── wifiNetworks/
│   │   │       │   │   │       ├── WifiDialog.qml
│   │   │       │   │   │       └── WifiNetworkItem.qml
│   │   │       │   │   ├── verticalBar/
│   │   │       │   │   │   ├── BatteryIndicator.qml
│   │   │       │   │   │   ├── Resource.qml
│   │   │       │   │   │   ├── Resources.qml
│   │   │       │   │   │   ├── VerticalBar.qml
│   │   │       │   │   │   ├── VerticalBarContent.qml
│   │   │       │   │   │   ├── VerticalClockWidget.qml
│   │   │       │   │   │   └── VerticalMedia.qml
│   │   │       │   │   └── wallpaperSelector/
│   │   │       │   │       ├── WallpaperDirectoryItem.qml
│   │   │       │   │       ├── WallpaperSelector.qml
│   │   │       │   │       └── WallpaperSelectorContent.qml
│   │   │       │   ├── settings/
│   │   │       │   │   ├── About.qml
│   │   │       │   │   ├── AdvancedConfig.qml
│   │   │       │   │   ├── BackgroundConfig.qml
│   │   │       │   │   ├── BarConfig.qml
│   │   │       │   │   ├── GeneralConfig.qml
│   │   │       │   │   ├── InterfaceConfig.qml
│   │   │       │   │   ├── QuickConfig.qml
│   │   │       │   │   └── ServicesConfig.qml
│   │   │       │   └── waffle/
│   │   │       │       ├── README.md
│   │   │       │       ├── actionCenter/
│   │   │       │       │   ├── ActionCenterContent.qml
│   │   │       │       │   ├── ActionCenterContext.qml
│   │   │       │       │   ├── ExpandableChoiceButton.qml
│   │   │       │       │   ├── HeaderRow.qml
│   │   │       │       │   ├── MediaPaneContent.qml
│   │   │       │       │   ├── SectionText.qml
│   │   │       │       │   ├── ToggleItem.qml
│   │   │       │       │   ├── WaffleActionCenter.qml
│   │   │       │       │   ├── bluetooth/
│   │   │       │       │   │   ├── BluetoothControl.qml
│   │   │       │       │   │   └── BluetoothDeviceItem.qml
│   │   │       │       │   ├── mainPage/
│   │   │       │       │   │   ├── MainPageBody.qml
│   │   │       │       │   │   ├── MainPageBodySliders.qml
│   │   │       │       │   │   ├── MainPageBodyToggles.qml
│   │   │       │       │   │   └── MainPageFooter.qml
│   │   │       │       │   ├── nightLight/
│   │   │       │       │   │   └── NightLightControl.qml
│   │   │       │       │   ├── toggles/
│   │   │       │       │   │   ├── ActionCenterToggleButton.qml
│   │   │       │       │   │   ├── ActionCenterTogglesDelegateChooser.qml
│   │   │       │       │   │   └── WNetworkToggle.qml
│   │   │       │       │   ├── volumeControl/
│   │   │       │       │   │   ├── VolumeControl.qml
│   │   │       │       │   │   └── VolumeEntry.qml
│   │   │       │       │   └── wifi/
│   │   │       │       │       ├── WWifiNetworkItem.qml
│   │   │       │       │       └── WifiControl.qml
│   │   │       │       ├── background/
│   │   │       │       │   └── WaffleBackground.qml
│   │   │       │       ├── bar/
│   │   │       │       │   ├── AppButton.qml
│   │   │       │       │   ├── BarButton.qml
│   │   │       │       │   ├── BarIconButton.qml
│   │   │       │       │   ├── BarMenu.qml
│   │   │       │       │   ├── BarPopup.qml
│   │   │       │       │   ├── BarToolTip.qml
│   │   │       │       │   ├── SearchButton.qml
│   │   │       │       │   ├── StartButton.qml
│   │   │       │       │   ├── SystemButton.qml
│   │   │       │       │   ├── TaskViewButton.qml
│   │   │       │       │   ├── TimeButton.qml
│   │   │       │       │   ├── UpdatesButton.qml
│   │   │       │       │   ├── WaffleBar.qml
│   │   │       │       │   ├── WaffleBarContent.qml
│   │   │       │       │   ├── WidgetsButton.qml
│   │   │       │       │   ├── tasks/
│   │   │       │       │   │   ├── TaskAppButton.qml
│   │   │       │       │   │   ├── TaskPreview.qml
│   │   │       │       │   │   ├── Tasks.qml
│   │   │       │       │   │   └── WindowPreview.qml
│   │   │       │       │   └── tray/
│   │   │       │       │       ├── Tray.qml
│   │   │       │       │       ├── TrayButton.qml
│   │   │       │       │       └── TrayOverflowMenu.qml
│   │   │       │       ├── lock/
│   │   │       │       │   └── WaffleLock.qml
│   │   │       │       ├── looks/
│   │   │       │       │   ├── AcrylicButton.qml
│   │   │       │       │   ├── AcrylicRectangle.qml
│   │   │       │       │   ├── BodyRectangle.qml
│   │   │       │       │   ├── CloseButton.qml
│   │   │       │       │   ├── FluentIcon.qml
│   │   │       │       │   ├── FooterRectangle.qml
│   │   │       │       │   ├── Looks.qml
│   │   │       │       │   ├── VerticalPageIndicator.qml
│   │   │       │       │   ├── WAmbientShadow.qml
│   │   │       │       │   ├── WAppIcon.qml
│   │   │       │       │   ├── WBarAttachedPanelContent.qml
│   │   │       │       │   ├── WBorderedButton.qml
│   │   │       │       │   ├── WBorderlessButton.qml
│   │   │       │       │   ├── WButton.qml
│   │   │       │       │   ├── WChoiceButton.qml
│   │   │       │       │   ├── WFadeLoader.qml
│   │   │       │       │   ├── WIcons.qml
│   │   │       │       │   ├── WIndeterminateProgressBar.qml
│   │   │       │       │   ├── WListView.qml
│   │   │       │       │   ├── WMenu.qml
│   │   │       │       │   ├── WMenuItem.qml
│   │   │       │       │   ├── WMouseAreaButton.qml
│   │   │       │       │   ├── WPane.qml
│   │   │       │       │   ├── WPanelIconButton.qml
│   │   │       │       │   ├── WPanelPageColumn.qml
│   │   │       │       │   ├── WPanelSeparator.qml
│   │   │       │       │   ├── WPopupToolTip.qml
│   │   │       │       │   ├── WProgressBar.qml
│   │   │       │       │   ├── WRectangularShadow.qml
│   │   │       │       │   ├── WRectangularShadowThis.qml
│   │   │       │       │   ├── WScrollBar.qml
│   │   │       │       │   ├── WSlider.qml
│   │   │       │       │   ├── WStackView.qml
│   │   │       │       │   ├── WSwitch.qml
│   │   │       │       │   ├── WText.qml
│   │   │       │       │   ├── WTextButton.qml
│   │   │       │       │   ├── WTextField.qml
│   │   │       │       │   ├── WTextInput.qml
│   │   │       │       │   ├── WTextWithFixedWidth.qml
│   │   │       │       │   ├── WToolTip.qml
│   │   │       │       │   ├── WToolTipContent.qml
│   │   │       │       │   ├── WToolbar.qml
│   │   │       │       │   ├── WToolbarButton.qml
│   │   │       │       │   ├── WToolbarIconButton.qml
│   │   │       │       │   ├── WToolbarIconTabButton.qml
│   │   │       │       │   ├── WToolbarSeparator.qml
│   │   │       │       │   ├── WToolbarTabBar.qml
│   │   │       │       │   └── WUserAvatar.qml
│   │   │       │       ├── notificationCenter/
│   │   │       │       │   ├── CalendarWidget.qml
│   │   │       │       │   ├── DateHeader.qml
│   │   │       │       │   ├── FocusFooter.qml
│   │   │       │       │   ├── NotificationCenterContent.qml
│   │   │       │       │   ├── NotificationHeaderButton.qml
│   │   │       │       │   ├── NotificationPaneContent.qml
│   │   │       │       │   ├── SmallBorderedIconAndTextButton.qml
│   │   │       │       │   ├── SmallBorderedIconButton.qml
│   │   │       │       │   ├── WNotificationAppIcon.qml
│   │   │       │       │   ├── WNotificationDismissAnim.qml
│   │   │       │       │   ├── WNotificationGroup.qml
│   │   │       │       │   ├── WSingleNotification.qml
│   │   │       │       │   └── WaffleNotificationCenter.qml
│   │   │       │       ├── notificationPopup/
│   │   │       │       │   └── WaffleNotificationPopup.qml
│   │   │       │       ├── onScreenDisplay/
│   │   │       │       │   ├── BrightnessOSD.qml
│   │   │       │       │   ├── OSDValue.qml
│   │   │       │       │   ├── VolumeOSD.qml
│   │   │       │       │   └── WaffleOSD.qml
│   │   │       │       ├── polkit/
│   │   │       │       │   ├── WPolkitContent.qml
│   │   │       │       │   └── WafflePolkit.qml
│   │   │       │       ├── screenSnip/
│   │   │       │       │   ├── WRectangularSelection.qml
│   │   │       │       │   ├── WRegionSelectionPanel.qml
│   │   │       │       │   └── WScreenSnip.qml
│   │   │       │       ├── sessionScreen/
│   │   │       │       │   ├── PowerButton.qml
│   │   │       │       │   ├── SessionScreenContent.qml
│   │   │       │       │   ├── WSessionScreenTextButton.qml
│   │   │       │       │   └── WaffleSessionScreen.qml
│   │   │       │       ├── startMenu/
│   │   │       │       │   ├── SearchBar.qml
│   │   │       │       │   ├── StartMenuContent.qml
│   │   │       │       │   ├── StartMenuContext.qml
│   │   │       │       │   ├── WaffleStartMenu.qml
│   │   │       │       │   ├── searchPage/
│   │   │       │       │   │   ├── SearchEntryIcon.qml
│   │   │       │       │   │   ├── SearchPageContent.qml
│   │   │       │       │   │   ├── SearchResultButton.qml
│   │   │       │       │   │   ├── SearchResults.qml
│   │   │       │       │   │   └── TagStrip.qml
│   │   │       │       │   └── startPage/
│   │   │       │       │       ├── AggregatedAppCategoryModel.qml
│   │   │       │       │       ├── AllAppsGrid.qml
│   │   │       │       │       ├── AppCategoryGrid.qml
│   │   │       │       │       ├── BigAppGrid.qml
│   │   │       │       │       ├── StartAppButton.qml
│   │   │       │       │       ├── StartPageApps.qml
│   │   │       │       │       ├── StartPageContent.qml
│   │   │       │       │       └── StartUserButton.qml
│   │   │       │       └── taskView/
│   │   │       │           ├── TaskViewContent.qml
│   │   │       │           ├── TaskViewWindow.qml
│   │   │       │           ├── TaskViewWorkspace.qml
│   │   │       │           ├── WaffleTaskView.qml
│   │   │       │           └── window-layout.js
│   │   │       ├── panelFamilies/
│   │   │       │   ├── IllogicalImpulseFamily.qml
│   │   │       │   ├── PanelLoader.qml
│   │   │       │   └── WaffleFamily.qml
│   │   │       ├── scripts/
│   │   │       │   ├── ai/
│   │   │       │   │   ├── gemini-categorize-wallpaper.sh
│   │   │       │   │   ├── gemini-translate.sh
│   │   │       │   │   └── show-installed-ollama-models.sh
│   │   │       │   ├── cava/
│   │   │       │   │   └── raw_output_config.txt
│   │   │       │   ├── colors/
│   │   │       │   │   ├── applycolor.sh
│   │   │       │   │   ├── code/
│   │   │       │   │   │   └── material-code-set-color.sh
│   │   │       │   │   ├── generate_colors_material.py
│   │   │       │   │   ├── random/
│   │   │       │   │   │   ├── random_konachan_wall.sh
│   │   │       │   │   │   └── random_osu_wall.sh
│   │   │       │   │   ├── scheme_for_image.py
│   │   │       │   │   ├── switchwall.sh
│   │   │       │   │   └── terminal/
│   │   │       │   │       ├── kitty-theme.conf
│   │   │       │   │       ├── scheme-base.json
│   │   │       │   │       └── sequences.txt
│   │   │       │   ├── hyprland/
│   │   │       │   │   └── hyprconfigurator.py
│   │   │       │   ├── images/
│   │   │       │   │   ├── find-regions-venv.sh
│   │   │       │   │   ├── find_regions.py
│   │   │       │   │   ├── least-busy-region-venv.sh
│   │   │       │   │   ├── least_busy_region.py
│   │   │       │   │   ├── text-color-venv.sh
│   │   │       │   │   └── text_color.py
│   │   │       │   ├── keyring/
│   │   │       │   │   ├── is_unlocked.sh
│   │   │       │   │   ├── try_lookup.sh
│   │   │       │   │   └── unlock.sh
│   │   │       │   ├── musicRecognition/
│   │   │       │   │   └── recognize-music.sh
│   │   │       │   ├── thumbnails/
│   │   │       │   │   ├── generate-thumbnails-magick.sh
│   │   │       │   │   ├── thumbgen-venv.sh
│   │   │       │   │   └── thumbgen.py
│   │   │       │   └── videos/
│   │   │       │       └── record.sh
│   │   │       ├── services/
│   │   │       │   ├── Ai.qml
│   │   │       │   ├── AppSearch.qml
│   │   │       │   ├── Audio.qml
│   │   │       │   ├── Battery.qml
│   │   │       │   ├── BluetoothStatus.qml
│   │   │       │   ├── Booru.qml
│   │   │       │   ├── BooruResponseData.qml
│   │   │       │   ├── Brightness.qml
│   │   │       │   ├── Cliphist.qml
│   │   │       │   ├── ConflictKiller.qml
│   │   │       │   ├── DateTime.qml
│   │   │       │   ├── EasyEffects.qml
│   │   │       │   ├── Emojis.qml
│   │   │       │   ├── FirstRunExperience.qml
│   │   │       │   ├── GlobalFocusGrab.qml
│   │   │       │   ├── GoogleCloud.qml
│   │   │       │   ├── HyprlandAntiFlashbangShader.qml
│   │   │       │   ├── HyprlandConfig.qml
│   │   │       │   ├── HyprlandData.qml
│   │   │       │   ├── HyprlandKeybinds.qml
│   │   │       │   ├── HyprlandXkb.qml
│   │   │       │   ├── Hyprsunset.qml
│   │   │       │   ├── Idle.qml
│   │   │       │   ├── KeyringStorage.qml
│   │   │       │   ├── LatexRenderer.qml
│   │   │       │   ├── LauncherApps.qml
│   │   │       │   ├── LauncherSearch.qml
│   │   │       │   ├── MaterialThemeLoader.qml
│   │   │       │   ├── MprisController.qml
│   │   │       │   ├── Network.qml
│   │   │       │   ├── Notifications.qml
│   │   │       │   ├── PolkitService.qml
│   │   │       │   ├── Privacy.qml
│   │   │       │   ├── ResourceUsage.qml
│   │   │       │   ├── SessionWarnings.qml
│   │   │       │   ├── SongRec.qml
│   │   │       │   ├── SystemInfo.qml
│   │   │       │   ├── TaskbarApps.qml
│   │   │       │   ├── TimerService.qml
│   │   │       │   ├── Todo.qml
│   │   │       │   ├── Translation.qml
│   │   │       │   ├── TrayService.qml
│   │   │       │   ├── Updates.qml
│   │   │       │   ├── Wallpapers.qml
│   │   │       │   ├── Weather.qml
│   │   │       │   ├── Ydotool.qml
│   │   │       │   ├── ai/
│   │   │       │   │   ├── AiMessageData.qml
│   │   │       │   │   ├── AiModel.qml
│   │   │       │   │   ├── ApiStrategy.qml
│   │   │       │   │   ├── GeminiApiStrategy.qml
│   │   │       │   │   ├── MistralApiStrategy.qml
│   │   │       │   │   └── OpenAiApiStrategy.qml
│   │   │       │   ├── gCloud/
│   │   │       │   │   ├── token-from-key-venv.sh
│   │   │       │   │   └── token_from_key.py
│   │   │       │   ├── hyprlandAntiFlashbangShader/
│   │   │       │   │   ├── anti-flashbang-weak.glsl
│   │   │       │   │   └── anti-flashbang.glsl
│   │   │       │   └── network/
│   │   │       │       └── WifiAccessPoint.qml
│   │   │       ├── settings.qml
│   │   │       ├── shell.qml
│   │   │       ├── translations/
│   │   │       │   ├── de_DE.json
│   │   │       │   ├── en_US.json
│   │   │       │   ├── es_MX.json
│   │   │       │   ├── fr_FR.json
│   │   │       │   ├── he_HE.json
│   │   │       │   ├── id_ID.json
│   │   │       │   ├── it_IT.json
│   │   │       │   ├── ja_JP.json
│   │   │       │   ├── pt_BR.json
│   │   │       │   ├── ru_RU.json
│   │   │       │   ├── tools/
│   │   │       │   │   ├── README.md
│   │   │       │   │   ├── guide/
│   │   │       │   │   │   ├── translation-tools-guide-zh_CN.md
│   │   │       │   │   │   └── translation-tools-guide.md
│   │   │       │   │   ├── manage-translations.sh
│   │   │       │   │   ├── translation-cleaner.py
│   │   │       │   │   └── translation-manager.py
│   │   │       │   ├── tr_TR.json
│   │   │       │   ├── uk_UA.json
│   │   │       │   ├── vi_VN.json
│   │   │       │   └── zh_CN.json
│   │   │       └── welcome.qml
│   │   ├── starship.toml
│   │   ├── thorium-flags.conf
│   │   ├── wlogout/
│   │   │   ├── layout
│   │   │   └── style.css
│   │   ├── xdg-desktop-portal/
│   │   │   └── hyprland-portals.conf
│   │   └── zshrc.d/
│   │       ├── auto-Hypr.sh
│   │       ├── dots-hyprland.zsh
│   │       └── shortcuts.zsh
│   └── .local/
│       └── share/
│           ├── icons/
│           │   └── illogical-impulse.svg
│           └── konsole/
│               └── Profile 1.profile
├── licenses/
│   ├── LGPL-3.0.txt
│   ├── MIT.txt
│   └── README.md
├── sdata/
│   ├── README.md
│   ├── deps-info.md
│   ├── dist-arch/
│   │   ├── .gitignore
│   │   ├── README.md
│   │   ├── illogical-impulse-audio/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-backlight/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-basic/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-bibata-modern-classic-bin/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-fonts-themes/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-hyprland/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-kde/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-microtex-git/
│   │   │   ├── .gitignore
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-portal/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-python/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-quickshell-git/
│   │   │   ├── .gitignore
│   │   │   ├── PKGBUILD
│   │   │   └── quickshell-check.hook
│   │   ├── illogical-impulse-screencapture/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-toolkit/
│   │   │   └── PKGBUILD
│   │   ├── illogical-impulse-widgets/
│   │   │   └── PKGBUILD
│   │   ├── install-deps.sh
│   │   ├── outdate-detect-mode
│   │   ├── previous_dependencies.conf
│   │   └── uninstall-deps.sh
│   ├── dist-fedora/
│   │   ├── .gitignore
│   │   ├── README.md
│   │   ├── feddeps.toml
│   │   ├── install-deps.sh
│   │   ├── outdate-detect-mode
│   │   └── uninstall-deps.sh
│   ├── dist-gentoo/
│   │   ├── README.md
│   │   ├── additional-useflags
│   │   ├── hyprland-qtutils-private.patch
│   │   ├── illogical-impulse-audio/
│   │   │   └── illogical-impulse-audio-1.0-r1.ebuild
│   │   ├── illogical-impulse-backlight/
│   │   │   └── illogical-impulse-backlight-1.0-r1.ebuild
│   │   ├── illogical-impulse-basic/
│   │   │   └── illogical-impulse-basic-1.0-r2.ebuild
│   │   ├── illogical-impulse-bibata-modern-classic-bin/
│   │   │   └── illogical-impulse-bibata-modern-classic-bin-2.0.6-r1.ebuild
│   │   ├── illogical-impulse-fonts-themes/
│   │   │   └── illogical-impulse-fonts-themes-1.0-r2.ebuild
│   │   ├── illogical-impulse-hyprland/
│   │   │   └── illogical-impulse-hyprland-1.0-r3.ebuild
│   │   ├── illogical-impulse-kde/
│   │   │   └── illogical-impulse-kde-1.0-r1.ebuild
│   │   ├── illogical-impulse-microtex-git/
│   │   │   └── illogical-impulse-microtex-git-1.0-r1.ebuild
│   │   ├── illogical-impulse-portal/
│   │   │   └── illogical-impulse-portal-1.0-r1.ebuild
│   │   ├── illogical-impulse-python/
│   │   │   └── illogical-impulse-python-1.1-r1.ebuild
│   │   ├── illogical-impulse-quickshell-git/
│   │   │   └── illogical-impulse-quickshell-git-0.1.0-r6.ebuild
│   │   ├── illogical-impulse-screencapture/
│   │   │   └── illogical-impulse-screencapture-1.0-r1.ebuild
│   │   ├── illogical-impulse-toolkit/
│   │   │   └── illogical-impulse-toolkit-1.0-r1.ebuild
│   │   ├── illogical-impulse-widgets/
│   │   │   └── illogical-impulse-widgets-1.0-r5.ebuild
│   │   ├── import-local-pkgs.sh
│   │   ├── install-deps.sh
│   │   ├── keywords
│   │   ├── local-pkgs/
│   │   │   └── fonts-and-themes/
│   │   │       ├── breeze-plus-6.2.5-r1.ebuild
│   │   │       ├── darkly-0.5.24-r1.ebuild
│   │   │       ├── material-symbols-variable-9999.ebuild
│   │   │       ├── readex-pro-1.0-r1.ebuild
│   │   │       ├── rubik-vf-1.0-r1.ebuild
│   │   │       └── space-grotesk-1.1.4-r1.ebuild
│   │   ├── outdate-detect-mode
│   │   ├── uninstall-deps.sh
│   │   └── useflags
│   ├── dist-nix/
│   │   ├── README.md
│   │   ├── home-manager/
│   │   │   ├── flake.lock
│   │   │   ├── flake.nix
│   │   │   ├── home.nix
│   │   │   └── quickshell.nix
│   │   ├── install-deps.sh
│   │   └── outdate-detect-mode
│   ├── lib/
│   │   ├── dist-determine.sh
│   │   ├── environment-variables.sh
│   │   ├── functions.sh
│   │   └── package-installers.sh
│   ├── subcmd-checkdeps/
│   │   ├── 0.run.sh
│   │   └── options.sh
│   ├── subcmd-exp-merge/
│   │   ├── 0.run.sh
│   │   └── options.sh
│   ├── subcmd-exp-update/
│   │   ├── 0.run.sh
│   │   ├── exp-update-tester.sh
│   │   └── options.sh
│   ├── subcmd-install/
│   │   ├── 0.greeting.sh
│   │   ├── 1.deps-router.sh
│   │   ├── 2.setups.sh
│   │   ├── 3.files-exp.sh
│   │   ├── 3.files-exp.yaml
│   │   ├── 3.files-legacy.sh
│   │   ├── 3.files.sh
│   │   └── options.sh
│   ├── subcmd-resetfirstrun/
│   │   ├── 0.run.sh
│   │   └── options.sh
│   ├── subcmd-uninstall/
│   │   ├── 0.run.sh
│   │   └── options.sh
│   ├── subcmd-virtmon/
│   │   ├── 0.run.sh
│   │   ├── hypr_mon_guard
│   │   └── options.sh
│   └── uv/
│       ├── README.md
│       ├── requirements.in
│       ├── requirements.txt
│       └── shell.nix
└── setup
```