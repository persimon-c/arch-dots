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







Quickshell.Services.Polkit Definitions
Polkit Agent
AuthFlow
PolkitAgent
Purpose of a Polkit Agent
PolKit is a system for privileged applications to query if a user is permitted to execute an action. You have probably seen it in the form of a “Please enter your password to continue with X” dialog box before. This dialog box is presented by your PolKit agent, it is a process running as your user that accepts authentication requests from the daemon and presents them to you to accept or deny.

This service enables writing a PolKit agent in Quickshell.

Implementing a Polkit Agent
The backend logic of communicating with the daemon is handled by the PolkitAgent object. It exposes incoming requests via PolkitAgent.flow and provides appropriate signals.

Flow of an authentication request
Incoming authentication requests are queued in the order that they arrive. If none is queued, a request starts processing right away. Otherwise, it will wait until prior requests are done.

A request starts by emitting the PolkitAgent.authenticationRequestStarted signal. At this point, information like the action to be performed and permitted users that can authenticate is available.

An authentication session for the request is immediately started, which internally starts a PAM conversation that is likely to prompt for user input.

Additional prompts may be shared with the user by way of the AuthFlow.supplementaryMessageChanged / AuthFlow.supplementaryIsErrorChanged signals and the AuthFlow.supplementaryMessage and AuthFlow.supplementaryIsError properties. A common message might be ‘Please input your password’.
An input request is forwarded via the AuthFlow.isResponseRequiredChanged / AuthFlow.inputPromptChanged / AuthFlow.responseVisibleChanged signals and the corresponding properties. Note that the request specifies whether the text box should show the typed input on screen or replace it with placeholders.
User replies can be submitted via the AuthFlow.submit method. A conversation can take multiple turns, for example if second factors are involved.

If authentication fails, we automatically create a fresh session so the user can try again. The AuthFlow.authenticationFailed signal is emitted in this case.

If authentication is successful, you receive the AuthFlow.authenticationSucceeded signal. At this point, the dialog can be closed. If additional requests are queued, you will receive the PolkitAgent.authenticationRequestStarted signal again.

Cancelled requests
Requests may either be canceled by the user or the PolKit daemon. In this case, we clean up any state and proceed to the next request, if any.

If the request was cancelled by the daemon and not the user, you also receive the AuthFlow.authenticationRequestCancelled signal.






Quickshell.Bluetooth Definitions
Bluetooth API
Bluetooth
Bluetooth manager

BluetoothAdapter
A Bluetooth adapter

BluetoothAdapterState
Power state of a Bluetooth adapter.

BluetoothDevice
A tracked Bluetooth device.

BluetoothDeviceState
Connection state of a Bluetooth device.

This module exposes Bluetooth management APIs provided by the BlueZ DBus interface. Both DBus and BlueZ must be running to use it.

See the Bluetooth singleton.





Quickshell.Networking Definitions
Network API
ConnectionFailReason
The reason a connection failed.

ConnectionState
The connection state of a device or network.

DeviceType
Type of a NetworkDevice.

NMSettings
A NetworkManager connection settings profile.

Network
A network.

NetworkBackendType
The backend supplying the Network service.

NetworkConnectivity
The degree to which the host can reach the internet.

NetworkDevice
A network device.

Networking
The Network service.

WifiDevice
WiFi variant of a NetworkDevice.

WifiDeviceMode
The 802.11 mode of a WifiDevice.

WifiNetwork
WiFi subtype of Network.

WifiSecurityType
The security type of a WifiNetwork.

WiredDevice
Wired variant of a NetworkDevice.

This module exposes Network management APIs provided by a supported network backend. For now, the only backend available is the NetworkManager DBus interface. Both DBus and NetworkManager must be running to use it.

See the Networking singleton.