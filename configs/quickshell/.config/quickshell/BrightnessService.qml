pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string _scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/scripts"
    property int brightness: 0
    property bool available: false

    property var _initProc: Process {
        command: ["bash", root._scriptsDir + "/get-brightness.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const n = parseInt(data, 10)
                if (!Number.isNaN(n)) {
                    root.brightness = n
                    root.available = true
                }
            }
        }
    }

    function setBrightness(percent) {
        root.brightness = Math.round(percent)
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = ["bash", root._scriptsDir + "/set-brightness.sh", String(Math.round(percent))]
        p.running = true
    }
}
