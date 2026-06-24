pragma Singleton
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import ".."

QtObject {
    id: root

    property string openPopup: ""
    readonly property bool anyPopupOpen: openPopup !== ""

    property bool volumeModalCentered: false
    property var primaryBarWindow: null
    property var trayMenuItem: null
    property var trayMenuItemShown: null
    property real trayMenuX: 0
    property real captureButtonCenterX: 0
    property bool anySliderDragging: false
    property string recordingMode: "none"
    property bool encoding: false
    property bool locked: false

    onLockedChanged: {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = ["i3-msg", root.locked ? 'mode "locked"' : 'mode "default"']
        p.running = true
    }

    property string primaryMonitor: ""
    property string secondaryMonitor: ""

    property real volumeButtonCenterX: 0
    property real backlightButtonCenterX: 0
    property real wifiButtonCenterX: 0
    property real bluetoothButtonCenterX: 0
    property real systemButtonCenterX: 0

    readonly property string desiredPopup:
        wifiHover.hovering ? "wifi" :
        volumeHover.hovering ? "volume" :
        backlightHover.hovering ? "backlight" :
        bluetoothHover.hovering ? "bluetooth" :
        systemHover.hovering ? "system" :
        calendarHover.hovering ? "calendar" :
        trayHover.hovering ? "tray" :
        captureHover.hovering ? "capture" : ""

    onDesiredPopupChanged: {
        root._closeTimer.stop()
        if (desiredPopup !== "") {
            root.openNow(desiredPopup)
        } else if (root.openPopup !== "") {
            root._closeTimer.restart()
        }
    }

    function openNow(name) {
        root._closeTimer.stop()
        root.openPopup = name
    }

    function _hoverFor(name) {
        return name === "wifi" ? root.wifiHover
            : name === "volume" ? root.volumeHover
            : name === "backlight" ? root.backlightHover
            : name === "bluetooth" ? root.bluetoothHover
            : name === "system" ? root.systemHover
            : name === "calendar" ? root.calendarHover
            : name === "tray" ? root.trayHover
            : name === "capture" ? root.captureHover : null
    }

    function closeNow(name) {
        if (root.openPopup !== name) return
        root.openPopup = ""
        const hover = root._hoverFor(name)
        if (hover) {
            hover.buttonHovered = false
            hover.popupHovered = false
        }
    }

    property var _closeTimer: Timer {
        interval: 150
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
    property var trayHover: HoverPopupController {}
    property var captureHover: HoverPopupController {}

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

    property var _lockToggle: Process {
        command: ["bash", "-c", "[ -p /tmp/qs-lock ] || mkfifo /tmp/qs-lock; while true; do cat /tmp/qs-lock; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: _ => root.locked = true
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
                    root.closeNow("capture")
                else if (!wasActive)
                    root.openNow("capture")
            } catch(_) {}
        }
    }
}
