import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 0

    function _run(args) {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    function _startRecord(mode) {
        ShellGlobals.recordingMode = mode
        _run(["bash", "-c", `setsid -f bash -c 'sleep 0.1 && ${Quickshell.env("HOME")}/.config/quickshell/scripts/start-record.sh ${mode}'`])
    }

    function _stopRecord() {
        ShellGlobals.recordingMode = "none"
        _run(["bash", "-c", `setsid -f bash -c 'sleep 0.1 && ${Quickshell.env("HOME")}/.config/quickshell/scripts/stop-record.sh'`])
        ShellGlobals.closeNow("capture")
    }

    function _screenshot() {
        _run(["bash", `${Quickshell.env("HOME")}/.config/quickshell/scripts/take-screenshot.sh`])
        ShellGlobals.closeNow("capture")
    }

    Text {
        visible: ShellGlobals.encoding
        text: "Encoding…"
        font.family: Theme.font
        font.pixelSize: 14
        color: Theme.gold
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 12
        Layout.bottomMargin: 12
    }

    SysMenuItem {
        visible: ShellGlobals.recordingMode === "none" && !ShellGlobals.encoding
        label: "Record GIF"
        onClicked: root._startRecord("gif")
    }

    SysMenuItem {
        visible: ShellGlobals.recordingMode === "none" && !ShellGlobals.encoding
        label: "Record MP4"
        onClicked: root._startRecord("mp4")
    }

    SysMenuItem {
        visible: ShellGlobals.recordingMode === "none" && !ShellGlobals.encoding
        label: "Screenshot"
        onClicked: root._screenshot()
    }

    SysMenuItem {
        visible: ShellGlobals.recordingMode !== "none"
        label: "Stop Recording"
        danger: true
        onClicked: root._stopRecord()
    }
}
