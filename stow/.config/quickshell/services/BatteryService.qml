pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

QtObject {
    id: root

    property string _scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/scripts"
    property bool available: false
    property int percent: 0
    property string status: "Unknown"
    property bool plugged: false
    readonly property bool charging: status === "Charging" || plugged

    property var _listener: Process {
        command: ["bash", root._scriptsDir + "/listen-battery.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.split(",")
                if (parts.length < 2) return
                const n = parseInt(parts[0], 10)
                if (Number.isNaN(n)) return
                root.percent = n
                root.status = parts[1]
                root.plugged = parts[2] === "1"
                root.available = true
            }
        }
    }
}
