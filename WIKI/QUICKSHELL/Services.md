Quickshell.Services.Pipewire Definitions
Pipewire API
Pipewire
Contains links to all pipewire objects.

PwAudioChannel
Audio channel of a pipewire node.

PwLink
A connection between pipewire nodes.

PwLinkGroup
A group of connections between pipewire nodes.

PwLinkState
State of a pipewire link.

PwNode
A node in the pipewire connection graph.

PwNodeAudio
Audio specific properties of pipewire nodes.

PwNodeLinkTracker
Tracks all link connections to a given node.

PwNodeType
The type of a pipewire node.

PwObjectTracker
Binds pipewire objects.


Quickshell.Services.UPower Definitions
UPower Service
PerformanceDegradationReason
Reason for performance degradation exposed by the PowerProfiles service.

PowerProfile
Power profile exposed by the PowerProfiles service.

PowerProfiles
Provides access to the Power Profiles service.

UPower
Provides access to the UPower service.

UPowerDevice
A device exposed through the UPower system service.

UPowerDeviceState
Power state of a UPower device.

UPowerDeviceType
Type of a UPower device.



Quickshell.Services.Mpris Definitions
Mpris Service
Mpris
MprisLoopState
Loop state of an MprisPlayer

MprisPlaybackState
Playback state of an MprisPlayer

MprisPlayer
A media player exposed over MPRIS.



Quickshell.Services.Notifications Definitions
Types for implementing a notification daemon
Notification
A notification emitted by a NotificationServer.

NotificationAction
An action associated with a Notification.

NotificationCloseReason
The reason a Notification was closed.

NotificationServer
Desktop Notifications Server.

NotificationUrgency
The urgency level of a Notification.




Quickshell.Services.SystemTray Definitions
Types for implementing a system tray
Category
Category of a StatusNotifierItem.

Status
Status of a StatusNotifierItem.

SystemTray
System tray

SystemTrayItem
An item in the system tray.




Quickshell.DBusMenu Definitions
Types related to DBusMenu (used in system tray)
DBusMenuHandle
Handle to a DBusMenu tree.

DBusMenuItem
Menu item shared by an external program.




Quickshell.Hyprland Definitions
Hyprland specific Quickshell types
GlobalShortcut
Hyprland global shortcut.

Hyprland
HyprlandEvent
Live Hyprland IPC event.

HyprlandFocusGrab
Input focus grabber

HyprlandMonitor
HyprlandWindow
Hyprland specific QsWindow properties.

HyprlandWorkspace



Quickshell.Io Definitions
Io types
DataStream
Data source that can be streamed into a parser.

DataStreamParser
Parser for streamed input data.

FileView
Simple accessor for small files.

FileViewAdapter
FileViewError
IpcHandler
Handler for IPC message calls.

JsonAdapter
FileView adapter for accessing JSON files.

JsonObject
Process
Child process.

Socket
Unix socket listener.

SocketServer
Unix socket server.

SplitParser
DataStreamParser for delimited data streams.

StdioCollector
DataStreamParser that collects all output into a buffer