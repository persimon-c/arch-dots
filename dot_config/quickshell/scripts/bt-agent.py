import sys
import os
import subprocess
from gi.repository import GLib, Gio

INTROSPECTION_XML = """
<node>
  <interface name="org.bluez.Agent1">
    <method name="Release">
    </method>
    <method name="RequestPinCode">
      <arg name="device" type="o" direction="in"/>
      <arg name="pin" type="s" direction="out"/>
    </method>
    <method name="DisplayPinCode">
      <arg name="device" type="o" direction="in"/>
      <arg name="pincode" type="s" direction="in"/>
    </method>
    <method name="RequestPasskey">
      <arg name="device" type="o" direction="in"/>
      <arg name="passkey" type="u" direction="out"/>
    </method>
    <method name="DisplayPasskey">
      <arg name="device" type="o" direction="in"/>
      <arg name="passkey" type="u" direction="in"/>
      <arg name="entered" type="q" direction="in"/>
    </method>
    <method name="RequestConfirmation">
      <arg name="device" type="o" direction="in"/>
      <arg name="passkey" type="u" direction="in"/>
    </method>
    <method name="RequestAuthorization">
      <arg name="device" type="o" direction="in"/>
    </method>
    <method name="AuthorizeService">
      <arg name="device" type="o" direction="in"/>
      <arg name="uuid" type="s" direction="in"/>
    </method>
    <method name="Cancel">
    </method>
  </interface>
</node>
"""

class BluetoothAgent:
    def __init__(self):
        self.node_info = Gio.DBusNodeInfo.new_for_xml(INTROSPECTION_XML)
        self.interface_info = self.node_info.interfaces[0]
        self.reg_id = 0

    def register(self, conn):
        self.reg_id = conn.register_object(
            "/org/quickshell/btagent",
            self.interface_info,
            self.handle_method_call,
            None,
            None
        )

    def handle_method_call(self, conn, sender, path, interface, method, params, invocation):
        print(f"Agent method call: {method} with params {params.unpack()}")
        
        if method == "Release":
            invocation.return_value(None)
            sys.exit(0)
            
        elif method == "RequestPinCode":
            device_path = params.unpack()[0]
            pin = self.ask_zenity(f"Enter PIN code for pairing device {device_path}:", entry=True)
            if pin:
                invocation.return_value(GLib.Variant("(s)", (pin,)))
            else:
                invocation.return_dbus_error("org.bluez.Error.Rejected", "Pairing rejected")
                
        elif method == "DisplayPinCode":
            device_path, pincode = params.unpack()
            self.show_zenity(f"Device {device_path} requires PIN code: {pincode}")
            invocation.return_value(None)
            
        elif method == "RequestPasskey":
            device_path = params.unpack()[0]
            passkey_str = self.ask_zenity(f"Enter Passkey for pairing device {device_path}:", entry=True)
            try:
                passkey = int(passkey_str)
                invocation.return_value(GLib.Variant("(u)", (passkey,)))
            except Exception:
                invocation.return_dbus_error("org.bluez.Error.Rejected", "Pairing rejected")
                
        elif method == "DisplayPasskey":
            device_path, passkey, entered = params.unpack()
            self.show_zenity(f"Confirm passkey on device: {passkey}")
            invocation.return_value(None)
            
        elif method == "RequestConfirmation":
            device_path, passkey = params.unpack()
            confirmed = self.ask_zenity(f"Do you confirm the passkey {passkey} matches on device {device_path}?")
            if confirmed:
                invocation.return_value(None)
            else:
                invocation.return_dbus_error("org.bluez.Error.Rejected", "Pairing rejected")
                
        elif method == "RequestAuthorization":
            device_path = params.unpack()[0]
            authorized = self.ask_zenity(f"Authorize pairing request from {device_path}?")
            if authorized:
                invocation.return_value(None)
            else:
                invocation.return_dbus_error("org.bluez.Error.Rejected", "Pairing rejected")
                
        elif method == "AuthorizeService":
            device_path, uuid = params.unpack()
            invocation.return_value(None) # Auto-authorize
            
        elif method == "Cancel":
            invocation.return_value(None)

    def show_zenity(self, text):
        subprocess.run(["/usr/bin/zenity", "--info", "--text", text, "--title=Bluetooth Pairing"])

    def ask_zenity(self, text, entry=False):
        if entry:
            res = subprocess.run(["/usr/bin/zenity", "--entry", "--text", text, "--title=Bluetooth Pairing"], capture_output=True, text=True)
            if res.returncode == 0:
                return res.stdout.strip()
            return None
        else:
            res = subprocess.run(["/usr/bin/zenity", "--question", "--text", text, "--title=Bluetooth Pairing"])
            return res.returncode == 0

def on_bus_acquired(conn, name):
    agent = BluetoothAgent()
    agent.register(conn)
    
    def on_registered(source, result, user_data):
        try:
            source.call_finish(result)
            print("Agent registered successfully with BlueZ!")
            
            # Request as default agent
            conn.call(
                "org.bluez",
                "/org/bluez",
                "org.bluez.AgentManager1",
                "RequestDefaultAgent",
                GLib.Variant("(o)", ("/org/quickshell/btagent",)),
                None,
                Gio.DBusCallFlags.NONE,
                -1,
                None,
                lambda src, res, ud: src.call_finish(res)
            )
        except Exception as e:
            print(f"Failed to register agent: {e}")
            sys.exit(1)

    conn.call(
        "org.bluez",
        "/org/bluez",
        "org.bluez.AgentManager1",
        "RegisterAgent",
        GLib.Variant("(os)", ("/org/quickshell/btagent", "KeyboardDisplay")),
        None,
        Gio.DBusCallFlags.NONE,
        -1,
        None,
        on_registered
    )

def main():
    Gio.bus_own_name(
        Gio.BusType.SYSTEM,
        "org.quickshell.BluetoothAgent",
        Gio.BusNameOwnerFlags.NONE,
        on_bus_acquired,
        None,
        None
    )
    
    loop = GLib.MainLoop()
    loop.run()

if __name__ == "__main__":
    main()
