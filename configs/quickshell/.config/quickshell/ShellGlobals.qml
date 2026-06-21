pragma Singleton
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string openPopup: ""
    property string pendingPopup: ""

    readonly property bool calendarOpen: openPopup === "calendar"
    readonly property bool volumeModalOpen: openPopup === "volume"
    readonly property bool systemMenuOpen: openPopup === "system"
    readonly property bool backlightModalOpen: openPopup === "backlight"
    readonly property bool wifiModalOpen: openPopup === "wifi"
    readonly property bool bluetoothModalOpen: openPopup === "bluetooth"
    readonly property bool anyPopupOpen: openPopup !== ""

    property bool volumeModalCentered: false
    property bool captureExpanded: false
    property var primaryBarWindow: null
    property bool anySliderDragging: false
    property string recordingMode: "none"
    property bool encoding: false

    property string primaryMonitor: ""
    property string secondaryMonitor: ""

    property real volumeButtonCenterX: 0
    property real backlightButtonCenterX: 0
    property real wifiButtonCenterX: 0
    property real bluetoothButtonCenterX: 0
    property real systemButtonCenterX: 0

    property bool calendarActive: false
    property bool volumeActive: false
    property bool systemActive: false
    property bool backlightActive: false
    property bool wifiActive: false
    property bool bluetoothActive: false
    readonly property bool anyActive: calendarActive || volumeActive || systemActive || backlightActive || wifiActive || bluetoothActive

    onAnyActiveChanged: {
        if (!anyActive && root.pendingPopup !== "") Qt.callLater(root._promotePending)
    }

    function _promotePending() {
        if (!root.anyActive && root.pendingPopup !== "") {
            root.openPopup = root.pendingPopup
            root.pendingPopup = ""
        }
    }

    readonly property string desiredPopup:
        wifiHover.hovering ? "wifi" :
        volumeHover.hovering ? "volume" :
        backlightHover.hovering ? "backlight" :
        bluetoothHover.hovering ? "bluetooth" :
        systemHover.hovering ? "system" :
        calendarHover.hovering ? "calendar" : ""

    onDesiredPopupChanged: {
        root._closeTimer.stop()
        if (desiredPopup !== "") {
            root.openNow(desiredPopup)
        } else if (root.openPopup !== "") {
            root._closeTimer.restart()
        }
    }

    function openNow(name) {
        if (root.openPopup === name) {
            root.pendingPopup = ""
            return
        }
        if (root.openPopup === "" && !root.anyActive) {
            root.openPopup = name
            root.pendingPopup = ""
        } else {
            if (root.openPopup !== "") root.openPopup = ""
            root.pendingPopup = name
        }
    }

    function closeNow(name) {
        if (root.pendingPopup === name) root.pendingPopup = ""
        if (root.openPopup === name) root.openPopup = ""
    }

    property var _closeTimer: Timer {
        interval: 300
        onTriggered: {
            if (root.desiredPopup !== "") return
            if (root.openPopup === "wifi" && root.wifiHover.suppressClose) return
            root.openPopup = ""
        }
    }

    property var calendarHover: HoverPopupController {}
    property var volumeHover: HoverPopupController {}
    property var systemHover: HoverPopupController {}
    property var backlightHover: HoverPopupController {}
    property var wifiHover: HoverPopupController {
        onSuppressCloseChanged: if (!suppressClose && root.desiredPopup === "" && root.openPopup === "wifi") root._closeTimer.restart()
    }
    property var bluetoothHover: HoverPopupController {}

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
                if (root.openPopup === "volume") root.closeNow("volume")
                else root.openNow("volume")
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
