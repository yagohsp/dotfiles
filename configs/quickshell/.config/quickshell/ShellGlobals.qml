pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool calendarOpen: false
    property bool volumeModalOpen: false
    property bool systemMenuOpen: false
    property bool captureExpanded: false
    property var primaryBarWindow: null
    property bool anySliderDragging: false
    property string recordingMode: "none"   // "none" | "gif" | "mp4"
    property bool encoding: false

    // start-record.sh / stop-record.sh write here instead of eww update
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
