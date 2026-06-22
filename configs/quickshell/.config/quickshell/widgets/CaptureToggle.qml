import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Row {
    id: root
    spacing: 0

    // Slide-out menu
    Item {
        width: menu.implicitWidth
        height: bar.height
        clip: true

        property real targetWidth: ShellGlobals.captureExpanded ? menu.implicitWidth + 4 : 0

        // drive the clip via the animated property
        Component.onCompleted: widthBinding.target = this
        Binding { id: widthBinding; property: "width"; value: root.children[0].targetWidth }

        Row {
            id: menu
            spacing: 4
            leftPadding: 2
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            // ── idle state ──────────────────────────────────────────────
            Row {
                spacing: 4
                visible: ShellGlobals.recordingMode === "none" && !ShellGlobals.encoding

                CaptureBtn { label: "GIF";   onClicked: _startRecord("gif") }
                CaptureBtn { label: "MP4";   onClicked: _startRecord("mp4") }
                CaptureBtn { label: "Print"; onClicked: _screenshot() }
            }

            // ── encoding ────────────────────────────────────────────────
            Text {
                visible: ShellGlobals.encoding
                text: "Encoding…"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                color: Theme.gold
                leftPadding: 6; rightPadding: 6
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            }

            // ── recording ───────────────────────────────────────────────
            CaptureBtn {
                visible: ShellGlobals.recordingMode !== "none"
                label: "Stop"
                danger: true
                onClicked: _stopRecord()
            }
        }
    }

    // Toggle button
    Rectangle {
        id: bar
        implicitWidth: icon.implicitWidth + 20
        implicitHeight: 36
        color: toggleMa.pressed ? Theme.highlightMed
             : toggleMa.containsMouse ? Theme.highlightLow
             : "transparent"
        radius: 4
        border.color: ShellGlobals.captureExpanded ? Theme.highlightMed : "transparent"
        border.width: 1


        Text {
            id: icon
            anchors.centerIn: parent
            text: "󰄀"
            font.family: Theme.font
            font.pixelSize: 20
            color: Theme.iris
        }

        MouseArea {
            id: toggleMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: ShellGlobals.captureExpanded = !ShellGlobals.captureExpanded
            cursorShape: Qt.PointingHandCursor
        }
    }

    // ── helpers ──────────────────────────────────────────────────────────

    function _run(args) {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    function _startRecord(mode) {
        ShellGlobals.recordingMode = mode   // immediate: panel switches to Stop
        _run(["bash", "-c", `setsid -f bash -c 'sleep 0.1 && ${Quickshell.env("HOME")}/.config/quickshell/scripts/start-record.sh ${mode}'`])
    }

    function _stopRecord() {
        ShellGlobals.recordingMode = "none"
        ShellGlobals.captureExpanded = false
        _run(["bash", "-c", `setsid -f bash -c 'sleep 0.1 && ${Quickshell.env("HOME")}/.config/quickshell/scripts/stop-record.sh'`])
    }

    function _screenshot() {
        ShellGlobals.captureExpanded = false
        _run(["bash", `${Quickshell.env("HOME")}/.config/quickshell/scripts/take-screenshot.sh`])
    }
}
