pragma Singleton
import QtQuick

// Icons — resolves icon names via Qt's built-in image://icons/ provider.
// Qt walks the XDG icon theme stack (Papirus → Papirus-Dark → hicolor fallback)
// so no manual path construction is needed.
//
// Usage:
//   Image { source: Icons.get("audio-volume-high") }
//   Image { source: Icons.get("battery-full-charging", 24) }
//   IconImage { source: Icons.get("network-wireless") }
//
// The size hint in the URL is advisory — Qt picks the nearest available size
// from the theme and scales if needed.

QtObject {
    id: root

    // ---------------------------------------------------------------------------
    // Primary resolver
    // Returns an image://icons/ URL for the given icon name and optional size.
    // ---------------------------------------------------------------------------
    function get(name: string, size: int): string {
        if (!name || name === "") return ""
        const s = (size > 0) ? size : 16
        return "image://icons/" + name + "?" + s
    }

    // ---------------------------------------------------------------------------
    // Semantic aliases
    // Keeps consumer code readable and centralises name changes.
    // ---------------------------------------------------------------------------

    // Audio
    readonly property string audioVolumeMuted:    "audio-volume-muted"
    readonly property string audioVolumeLow:      "audio-volume-low"
    readonly property string audioVolumeMedium:   "audio-volume-medium"
    readonly property string audioVolumeHigh:     "audio-volume-high"
    readonly property string audioHeadphones:     "audio-headphones"
    readonly property string audioMicrophone:     "audio-input-microphone"
    readonly property string audioMicrophoneMuted:"audio-input-microphone-muted"

    // Battery
    readonly property string batteryFull:         "battery-full"
    readonly property string batteryGood:         "battery-good"
    readonly property string batteryLow:          "battery-low"
    readonly property string batteryCaution:      "battery-caution"
    readonly property string batteryEmpty:        "battery-empty"
    readonly property string batteryCharging:     "battery-full-charging"
    readonly property string batteryMissing:      "battery-missing"

    // Network — wireless
    readonly property string networkWireless:          "network-wireless"
    readonly property string networkWirelessSignalExcellent: "network-wireless-signal-excellent"
    readonly property string networkWirelessSignalGood:      "network-wireless-signal-good"
    readonly property string networkWirelessSignalOk:        "network-wireless-signal-ok"
    readonly property string networkWirelessSignalWeak:      "network-wireless-signal-weak"
    readonly property string networkWirelessSignalNone:      "network-wireless-signal-none"
    readonly property string networkWirelessDisconnected:    "network-wireless-disconnected"
    readonly property string networkWirelessOffline:         "network-wireless-offline"
    // Network — wired
    readonly property string networkWired:             "network-wired"
    readonly property string networkWiredDisconnected: "network-wired-disconnected"
    readonly property string networkOffline:           "network-offline"
    readonly property string networkTransmitReceive:   "network-transmit-receive"
    readonly property string networkVpn:               "network-vpn"

    // Bluetooth
    readonly property string bluetooth:                "bluetooth"
    readonly property string bluetoothActive:          "bluetooth-active"
    readonly property string bluetoothDisabled:        "bluetooth-disabled"

    // Brightness
    readonly property string brightnessHigh:      "display-brightness-high"
    readonly property string brightnessMedium:    "display-brightness-medium"
    readonly property string brightnessLow:       "display-brightness-low"
    readonly property string brightnessOff:       "display-brightness-off"

    // Media / MPRIS
    readonly property string mediaPlay:           "media-playback-start"
    readonly property string mediaPause:          "media-playback-pause"
    readonly property string mediaStop:           "media-playback-stop"
    readonly property string mediaNext:           "media-skip-forward"
    readonly property string mediaPrevious:       "media-skip-backward"
    readonly property string mediaRecord:         "media-record"
    readonly property string mediaShuffle:        "media-playlist-shuffle"
    readonly property string mediaRepeat:         "media-playlist-repeat"
    readonly property string mediaRepeatOne:      "media-playlist-repeat-song"
    readonly property string mediaAlbum:          "media-optical"

    // Notifications
    readonly property string notificationNew:     "notification-new"
    readonly property string notificationClear:   "edit-clear-all"
    readonly property string bellRing:            "notification"
    readonly property string bellOff:             "notifications-disabled"

    // Power / Session
    readonly property string powerOff:            "system-shutdown"
    readonly property string reboot:              "system-reboot"
    readonly property string suspend:             "system-suspend"
    readonly property string hibernate:           "system-hibernate"
    readonly property string lock:                "system-lock-screen"
    readonly property string logout:              "system-log-out"
    readonly property string powerSave:           "power-profile-power-saver"
    readonly property string powerBalanced:       "power-profile-balanced"
    readonly property string powerPerformance:    "power-profile-performance"

    // System tray / generic UI
    readonly property string settings:            "preferences-system"
    readonly property string settingsApp:         "applications-system"
    readonly property string search:              "system-search"
    readonly property string close:               "window-close"
    readonly property string minimize:            "window-minimize"
    readonly property string maximize:            "window-maximize"
    readonly property string keyboard:            "input-keyboard"
    readonly property string mouse:               "input-mouse"
    readonly property string touchpad:            "input-touchpad"
    readonly property string monitor:             "video-display"
    readonly property string printer:             "printer"
    readonly property string camera:              "camera-photo"
    readonly property string terminal:            "utilities-terminal"
    readonly property string fileManager:         "system-file-manager"
    readonly property string browser:             "applications-internet"
    readonly property string mail:                "internet-mail"
    readonly property string calendar:            "x-office-calendar"
    readonly property string calculator:          "accessories-calculator"
    readonly property string clipboard:           "edit-paste"
    readonly property string colorPicker:         "color-picker"
    readonly property string screenshot:          "applets-screenshooter"
    readonly property string record:              "media-record"
    readonly property string eye:                 "view-visible"
    readonly property string eyeOff:              "view-hidden"
    readonly property string refresh:             "view-refresh"
    readonly property string add:                 "list-add"
    readonly property string remove:              "list-remove"
    readonly property string edit:                "document-edit"
    readonly property string save:                "document-save"
    readonly property string open:                "document-open"
    readonly property string trash:               "user-trash"
    readonly property string trashFull:           "user-trash-full"
    readonly property string copy:                "edit-copy"
    readonly property string cut:                 "edit-cut"
    readonly property string paste:               "edit-paste"
    readonly property string undo:                "edit-undo"
    readonly property string redo:                "edit-redo"
    readonly property string arrowUp:             "go-up"
    readonly property string arrowDown:           "go-down"
    readonly property string arrowLeft:           "go-previous"
    readonly property string arrowRight:          "go-next"
    readonly property string chevronUp:           "pan-up-symbolic"
    readonly property string chevronDown:         "pan-down-symbolic"
    readonly property string info:                "dialog-information"
    readonly property string warning:             "dialog-warning"
    readonly property string error:               "dialog-error"
    readonly property string question:            "dialog-question"
    readonly property string success:             "emblem-default"
    readonly property string star:                "starred"
    readonly property string starOff:             "non-starred"
    readonly property string pin:                 "mark-location"
    readonly property string tag:                 "tag"
    readonly property string user:                "user-identity"
    readonly property string users:               "system-users"
    readonly property string group:               "user-group-properties"
    readonly property string home:                "user-home"
    readonly property string network:             "network-workgroup"
    readonly property string folder:              "folder"
    readonly property string folderOpen:          "folder-open"
    readonly property string document:            "x-office-document"
    readonly property string image:               "image-x-generic"
    readonly property string video:               "video-x-generic"
    readonly property string music:               "audio-x-generic"
    readonly property string archive:             "package-x-generic"
    readonly property string code:                "text-x-script"
    readonly property string emoji:               "face-smile"
    readonly property string idle:                "caffeine-cup-empty"
    readonly property string nightMode:           "night-light"
    readonly property string gpu:                 "video-card"
    readonly property string cpu:                 "cpu"
    readonly property string ram:                 "memory"
    readonly property string temperature:         "temperature"
    readonly property string disk:                "drive-harddisk"
    readonly property string sdCard:              "media-flash-sd-mmc"
    readonly property string usb:                 "drive-removable-media-usb"
    readonly property string wallpaper:           "preferences-desktop-wallpaper"
    readonly property string theme:               "preferences-desktop-theme"
    readonly property string font:                "preferences-desktop-font"
    readonly property string gear:                "preferences-other"
    readonly property string timer:               "timer"
    readonly property string stopwatch:           "chronometer"
    readonly property string github:              "github"           // Papirus has this
    readonly property string archLinux:           "archlinux-logo"   // Papirus has this

    // ---------------------------------------------------------------------------
    // Battery helper — returns the right icon name for a given level + charging
    // ---------------------------------------------------------------------------
    function batteryIcon(level: real, charging: bool): string {
        if (charging) return batteryCharging
        if (level >= 90) return batteryFull
        if (level >= 60) return batteryGood
        if (level >= 30) return batteryLow
        if (level >= 10) return batteryCaution
        return batteryEmpty
    }

    // ---------------------------------------------------------------------------
    // Wireless signal helper — returns the right icon name for a given strength
    // strength is 0–100
    // ---------------------------------------------------------------------------
    function wifiIcon(strength: real, connected: bool): string {
        if (!connected) return networkWirelessDisconnected
        if (strength >= 80) return networkWirelessSignalExcellent
        if (strength >= 60) return networkWirelessSignalGood
        if (strength >= 40) return networkWirelessSignalOk
        if (strength >= 20) return networkWirelessSignalWeak
        return networkWirelessSignalNone
    }

    // ---------------------------------------------------------------------------
    // Volume helper — returns the right icon name for a given level + muted
    // level is 0–100
    // ---------------------------------------------------------------------------
    function volumeIcon(level: real, muted: bool): string {
        if (muted || level <= 0) return audioVolumeMuted
        if (level < 33) return audioVolumeLow
        if (level < 66) return audioVolumeMedium
        return audioVolumeHigh
    }

    // ---------------------------------------------------------------------------
    // Brightness helper — level is 0–100
    // ---------------------------------------------------------------------------
    function brightnessIcon(level: real): string {
        if (level <= 0)  return brightnessOff
        if (level < 33)  return brightnessLow
        if (level < 66)  return brightnessMedium
        return brightnessHigh
    }
}
