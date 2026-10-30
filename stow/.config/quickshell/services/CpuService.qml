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
    property var processes: []
    property string killError: ""

    property var _listener: Process {
        command: ["python3", root._scriptsDir + "/listen-cpu.py"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root._parseSnapshot(line)
        }
    }

    function _parseSnapshot(text) {
        let data
        try {
            data = JSON.parse(text)
        } catch (_) {
            return
        }
        root.available = true
        root.percent = data.cpu ?? 0
        root.processes = data.processes ?? []
    }

    property Component _procComponent: Component {
        Process {
            id: proc
            property int targetPid: 0
            onExited: exitCode => {
                if (exitCode !== 0)
                    root.killError = "failed to kill pid " + targetPid
                else
                    root.killError = ""
                destroy()
            }
        }
    }

    function killProcess(pid) {
        if (!pid) return
        root.killError = ""
        const p = root._procComponent.createObject(root, {
            command: ["bash", root._scriptsDir + "/kill-process.sh", String(pid)],
            targetPid: pid
        })
        p.running = true
    }

    function killProcesses(pids) {
        if (!pids || pids.length === 0) return
        for (const pid of pids)
            root.killProcess(pid)
    }
}
