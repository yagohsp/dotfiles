pragma Singleton
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool calendarOpen: false
    property bool volumeModalOpen: false
    property bool volumeModalCentered: false
    property bool systemMenuOpen: false
    property bool backlightModalOpen: false
    property bool wifiModalOpen: false
    property bool anyPopupOpen: calendarOpen || volumeModalOpen || systemMenuOpen || backlightModalOpen || wifiModalOpen
    property bool captureExpanded: false
    property var primaryBarWindow: null
    property bool anySliderDragging: false
    property string recordingMode: "none"   // "none" | "gif" | "mp4"
    property bool encoding: false

    property string primaryMonitor: ""
    property string secondaryMonitor: ""

    // Window-local x of each bar button's horizontal center, kept up to date
    // by the button itself, so its popup can anchor under it instead of a
    // fixed corner.
    property real volumeButtonCenterX: 0
    property real backlightButtonCenterX: 0
    property real wifiButtonCenterX: 0
    property real systemButtonCenterX: 0

    property var _monitorsEnv: FileView {
        path: Quickshell.env("HOME") + "/dotfiles/monitors.env"
        watchChanges: true
        onTextChanged: {
            for (const line of text().split("\n")) {
                const m = line.match(/^([A-Z_]+)="?([^"]*)"?$/)
                if (!m) continue
                if (m[1] === "PRIMARY_MONITOR") root.primaryMonitor = m[2]
                if (m[1] === "SECONDARY_MONITOR") root.secondaryMonitor = m[2]
            }
        }
    }

    property var _volumeModalToggle: Process {
        command: ["bash", "-c", "[ -p /tmp/qs-volume-modal ] || mkfifo /tmp/qs-volume-modal; while true; do cat /tmp/qs-volume-modal; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: _ => {
                root.volumeModalCentered = true
                root.volumeModalOpen = !root.volumeModalOpen
            }
        }
    }

    property var _captureState: FileView {
        path: "/tmp/qs-capture.json"
        onTextChanged: {
            try {
                const d = JSON.parse(text)
                const wasActive = root.recordingMode !== "none" || root.encoding
                root.recordingMode = d.recordingMode ?? "none"
                root.encoding      = d.encoding      ?? false
                const isActive = root.recordingMode !== "none" || root.encoding
                if (!isActive)
                    root.captureExpanded = false
                else if (!wasActive)
                    root.captureExpanded = true
            } catch(_) {}
        }
    }
}
