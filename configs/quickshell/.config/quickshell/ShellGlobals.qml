pragma Singleton
import QtQuick
import QtQuick.Window
import Quickshell.Io

QtObject {
    id: root

    property bool calendarOpen: false
    property bool volumeModalOpen: false
    property bool volumeModalCentered: false
    property bool systemMenuOpen: false
    property bool anyPopupOpen: calendarOpen || volumeModalOpen || systemMenuOpen
    property bool captureExpanded: false
    property var primaryBarWindow: null
    property bool anySliderDragging: false
    property string recordingMode: "none"   // "none" | "gif" | "mp4"
    property bool encoding: false

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
