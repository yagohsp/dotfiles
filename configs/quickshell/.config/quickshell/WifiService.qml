pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string _scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/scripts"
    property bool available: false
    property bool radioEnabled: false
    property bool scanning: false
    property string activeSsid: ""
    property int activeSignal: 0
    property var networks: []
    property string connectError: ""
    property bool connecting: false
    property var savedConnections: []

    readonly property bool connected: activeSsid !== ""

    // Connection profile names default to the SSID when created via `nmcli
    // device wifi connect`/most GUIs, and forget() relies on that same
    // assumption — so name equality is a reliable enough saved-profile check
    // without an extra per-connection SSID lookup.
    function hasSavedProfile(ssid) {
        return root.savedConnections.includes(ssid)
    }

    property Component _savedConnectionsProcComponent: Component {
        Process {
            id: proc
            stdout: StdioCollector {
                id: out
                onStreamFinished: {
                    const names = []
                    for (const line of out.text.split("\n")) {
                        if (!line) continue
                        const idx = line.lastIndexOf(":")
                        if (idx === -1) continue
                        if (line.slice(idx + 1) === "802-11-wireless") names.push(line.slice(0, idx))
                    }
                    root.savedConnections = names
                }
            }
            onExited: proc.destroy()
        }
    }

    function refreshSavedConnections() {
        const p = root._savedConnectionsProcComponent.createObject(root, {
            command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        })
        p.running = true
    }

    Component.onCompleted: root.refreshSavedConnections()

    // nmcli's terse/-g output escapes literal ':' in field values (e.g. BSSID)
    // as '\:'. Protect those with a placeholder before splitting on ':' so
    // real field separators aren't confused with escaped ones, then restore
    // the placeholder back to ':' only within each extracted field.
    function _parseSnapshot(lines) {
        if (lines.length === 0) return

        root.radioEnabled = lines[0] === "radio:enabled"
        root.available = true

        if (!root.radioEnabled) {
            root.networks = []
            root.activeSsid = ""
            root.activeSignal = 0
            return
        }

        const placeholder = "\u0001"
        const byKey = new Map()

        for (let i = 1; i < lines.length; i++) {
            const line = lines[i]
            if (!line) continue

            const fields = line.replace(/\\:/g, placeholder).split(":")
            if (fields.length < 6) continue

            const active = fields[0] === "yes"
            const signal = parseInt(fields[1], 10) || 0
            const freq = fields[2]
            const ssid = fields[3].split(placeholder).join(":").trim()
            const bssid = fields[4].split(placeholder).join(":")
            const security = fields[5]

            if (!ssid) continue

            const existing = byKey.get(ssid)
            if (!existing || active || (!existing.active && signal > existing.signal)) {
                byKey.set(ssid, { ssid, signal, freq, bssid, security, active })
            }
        }

        const list = Array.from(byKey.values()).sort((a, b) => b.signal - a.signal)
        root.networks = list

        const active = list.find(n => n.active)
        root.activeSsid = active ? active.ssid : ""
        root.activeSignal = active ? active.signal : 0
    }

    property var _buffer: []
    property var _listener: Process {
        command: ["bash", root._scriptsDir + "/listen-wifi.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                if (line === "---") {
                    root._parseSnapshot(root._buffer)
                    root._buffer = []
                } else {
                    root._buffer.push(line)
                }
            }
        }
    }

    function toggleRadio() {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = ["nmcli", "radio", "wifi", root.radioEnabled ? "off" : "on"]
        p.running = true
    }

    function rescan() {
        root.scanning = true
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = ["nmcli", "device", "wifi", "list", "--rescan", "yes"]
        p.running = true
        p.onExited.connect(() => { root.scanning = false })
    }

    property Component _connectProcComponent: Component {
        Process {
            id: proc
            property string capturedStderr: ""
            stderr: SplitParser {
                splitMarker: "\n"
                onRead: line => proc.capturedStderr += line
            }
            onExited: exitCode => {
                root.connecting = false
                if (exitCode !== 0) {
                    root.connectError = /Secrets were required|802-11-wireless-security|password/i.test(proc.capturedStderr)
                        ? "needs-password"
                        : (proc.capturedStderr || "connection failed")
                } else {
                    root.refreshSavedConnections()
                }
                proc.destroy()
            }
        }
    }

    function connect(ssid, password) {
        root.connectError = ""
        root.connecting = true
        const p = root._connectProcComponent.createObject(root, {
            command: password
                ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
                : ["nmcli", "device", "wifi", "connect", ssid]
        })
        p.running = true
    }

    function disconnect() {
        // `nmcli device disconnect` requires the real interface name (e.g.
        // "wlan0"), not the device type "wifi" — look it up at call time.
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = ["bash", "-c", "nmcli device disconnect \"$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2==\"wifi\"{print $1; exit}')\""]
        p.running = true
    }

    function forget(ssid) {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = ["nmcli", "connection", "delete", ssid]
        p.onExited.connect(() => root.refreshSavedConnections())
        p.running = true
    }
}
