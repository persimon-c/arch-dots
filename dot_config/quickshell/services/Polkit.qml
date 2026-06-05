import QtQuick
import Quickshell
import Quickshell.Services.Polkit

/**
 * Polkit.qml — Polkit agent service
 *
 * Wraps PolkitAgent and normalises the AuthFlow into flat, bindable
 * properties that PolkitDialog.qml can bind to directly without
 * ever touching the raw Quickshell Polkit API.
 *
 * Ownership: instantiated as a child object inside PolkitDialog.qml.
 * Not a Singleton — PolkitAgent must be instantiated exactly once, and
 * PolkitDialog owns that lifetime.
 *
 * PolkitDialog.qml interface:
 *   - Bind to `active` to show/hide the dialog window
 *   - Bind to the flat properties below for all display values
 *   - Call `submit(password)` when the user confirms
 *   - Call `cancel()` when the user dismisses
 *   - Listen to `authFailed` to shake the input field / show error
 *   - Listen to `authSucceeded` to close the dialog
 */
QtObject {
    id: root

    // ─── Public — dialog visibility ─────────────────────────────────────────

    /** True when an auth request is active and the dialog should be shown. */
    readonly property bool active: agent.isActive

    // ─── Public — display properties (flat, safe to bind when !active) ──────

    /** Main message from the daemon, e.g. "Authentication Required" */
    readonly property string message: agent.flow ? agent.flow.message : ""

    /** Label for the input field, e.g. "Password:" */
    readonly property string inputPrompt: agent.flow ? agent.flow.inputPrompt : ""

    /** Whether the input field should show typed text (false = password mode) */
    readonly property bool responseVisible: agent.flow ? agent.flow.responseVisible : false

    /** Whether the daemon is currently waiting for user input */
    readonly property bool isResponseRequired: agent.flow ? agent.flow.isResponseRequired : false

    /** Supplementary message (PAM info, e.g. "Incorrect password, try again") */
    readonly property string supplementaryMessage: agent.flow ? agent.flow.supplementaryMessage : ""

    /** True if supplementaryMessage is an error (show in red) */
    readonly property bool supplementaryIsError: agent.flow ? agent.flow.supplementaryIsError : false

    /** Action ID — machine-readable, e.g. "org.freedesktop.packagekit.system-update" */
    readonly property string actionId: agent.flow ? agent.flow.actionId : ""

    /** Icon name (FreeDesktop spec) associated with the action */
    readonly property string iconName: agent.flow ? agent.flow.iconName : ""

    /** True if at least one prior attempt in this flow has failed */
    readonly property bool failed: agent.flow ? agent.flow.failed : false

    /** True if the request was cancelled (by daemon or user) */
    readonly property bool isCancelled: agent.flow ? agent.flow.isCancelled : false

    /** Available identities that can authenticate (list of identity objects) */
    readonly property var identities: agent.flow ? agent.flow.identities : []

    /** Currently selected identity */
    readonly property var selectedIdentity: agent.flow ? agent.flow.selectedIdentity : null

    // ─── Public — actions ────────────────────────────────────────────────────

    /** Submit the user's response (password or other PAM input). */
    function submit(value) {
        if (agent.flow && agent.isActive) {
            agent.flow.submit(value)
        }
    }

    /** Cancel the current auth request from the user side. */
    function cancel() {
        if (agent.flow && agent.isActive) {
            agent.flow.cancelAuthenticationRequest()
        }
    }

    /**
     * Change the authenticating identity.
     * Pass one of the objects from the `identities` list.
     * This aborts any ongoing PAM conversation and starts a fresh one.
     */
    function selectIdentity(identity) {
        if (agent.flow) {
            agent.flow.selectedIdentity = identity
        }
    }

    // ─── Public — signals ────────────────────────────────────────────────────

    /** Emitted when a new auth request arrives. Dialog should open/reset. */
    signal authRequestStarted()

    /** Emitted when a PAM attempt fails. Dialog should shake input + clear field. */
    signal authFailed()

    /** Emitted when auth succeeds. Dialog should close. */
    signal authSucceeded()

    /**
     * Emitted when the daemon cancels the request (not the user).
     * Dialog should close and optionally show a brief "Cancelled" message.
     */
    signal authCancelled()

    // ─── Internal — PolkitAgent ───────────────────────────────────────────────

    property PolkitAgent _agent: PolkitAgent {
        id: agent

        // Default D-Bus path is /org/quickshell/Polkit — no need to override.

        onAuthenticationRequestStarted: {
            console.log("[Polkit] auth request started — action:", root.actionId)
            root.authRequestStarted()
        }
    }

    // AuthFlow signals — connect via Connections because flow is a property
    // that can be null, so we must watch the flow object itself.
    property Connections _flowConnections: Connections {
        target: agent.flow

        // PAM attempt failed — a new session has already been started by QS
        function onAuthenticationFailed() {
            console.log("[Polkit] authentication failed")
            root.authFailed()
        }

        // PAM succeeded
        function onAuthenticationSucceeded() {
            console.log("[Polkit] authentication succeeded")
            root.authSucceeded()
        }

        // Daemon cancelled the request (not the user)
        function onAuthenticationRequestCancelled() {
            console.log("[Polkit] request cancelled by daemon")
            root.authCancelled()
        }
    }

    Component.onCompleted: {
        if (agent.isRegistered) {
            console.log("[Polkit] agent registered at", agent.path)
        } else {
            console.warn("[Polkit] agent failed to register — is polkit daemon running?")
        }
    }
}
