pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property var workspaces: []

    property var _proc: Process {
        command: ["bash", "/home/yago/.config/quickshell/scripts/workspaces-all.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try { root.workspaces = JSON.parse(data) } catch(_) {}
            }
        }
    }
}
