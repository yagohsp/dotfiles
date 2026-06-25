pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

QtObject {
    id: root

    property string _scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/scripts"

    property bool checkingAuth: true
    property bool authenticated: false
    property bool authenticating: false
    property string authError: ""

    property var events: []

    function _parseSnapshot(lines) {
        if (lines.length === 0) return

        const status = lines[0]
        root.checkingAuth = false

        if (status === "NOAUTH") {
            root.authenticated = false
            root.events = []
            return
        }
        if (status === "NOTOOL") {
            root.authenticated = false
            root.authError = "gcalcli not installed"
            root.events = []
            return
        }
        if (status === "ERROR") {
            root.authenticated = false
            root.authError = "failed to fetch events"
            root.events = []
            return
        }

        root.authenticated = true
        root.authError = ""

        const parsed = []
        for (let i = 1; i < lines.length; i++) {
            const line = lines[i]
            if (!line) continue
            const fields = line.split("\t")
            if (fields.length < 5) continue

            const [startDate, startTime, endDate, endTime, title, description] = fields
            const parsedDate = new Date(startDate)
            parsed.push({
                startDate, startTime, endDate, endTime, title,
                isHoliday: (description || "").trim() === "Feriado",
                dateKey: Number.isNaN(parsedDate.getTime()) ? "" :
                    `${parsedDate.getFullYear()}-${parsedDate.getMonth()}-${parsedDate.getDate()}`
            })
        }
        root.events = parsed
    }

    function eventsOnDate(date) {
        const key = `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`
        return root.events.filter(e => e.dateKey === key)
    }

    property var _buffer: []
    property var _listener: Process {
        command: ["bash", root._scriptsDir + "/listen-calendar.sh"]
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

    property string authUrl: ""

    property Component _loginProcComponent: Component {
        Process {
            id: proc
            property string capturedStderr: ""
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: line => {
                    if (line.startsWith("AUTHURL:")) root.authUrl = line.slice(8)
                }
            }
            stderr: SplitParser {
                splitMarker: "\n"
                onRead: line => proc.capturedStderr += line
            }
            onExited: exitCode => {
                root.authenticating = false
                if (exitCode !== 0) {
                    root.authError = proc.capturedStderr || "login failed"
                } else {
                    root.authError = ""
                    root.authUrl = ""
                    root.authenticated = true
                }
                proc.destroy()
            }
        }
    }

    function login(clientId, clientSecret) {
        root.authError = ""
        root.authUrl = ""
        root.authenticating = true
        const p = root._loginProcComponent.createObject(root, {
            command: ["bash", root._scriptsDir + "/gcalcli-login.sh", clientId, clientSecret]
        })
        p.running = true
    }

    property Component _importProcComponent: Component {
        Process {
            id: proc
            property var capturedLines: []
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: line => proc.capturedLines.push(line)
            }
            onExited: exitCode => {
                if (exitCode === 0 && proc.capturedLines.length >= 2) {
                    root.login(proc.capturedLines[0], proc.capturedLines[1])
                } else if (exitCode === 1) {
                    root.authError = "no client_secret*.json found in ~/.config/quickshell"
                } else if (exitCode === 5) {
                    root.authError = "that client_secret.json is a 'Web application' client; recreate it as 'Desktop app' in Cloud Console"
                } else {
                    root.authError = "couldn't read credentials file"
                }
                proc.destroy()
            }
        }
    }

    function importFromDownloads() {
        root.authError = ""
        const p = root._importProcComponent.createObject(root, {
            command: ["bash", root._scriptsDir + "/find-gcalcli-credentials.sh"]
        })
        p.running = true
    }

    property bool refreshing: false

    property Component _refreshProcComponent: Component {
        Process {
            id: proc
            property var capturedLines: []
            command: ["bash", root._scriptsDir + "/refresh-calendar.sh"]
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: line => {
                    if (line === "---") {
                        root._parseSnapshot(proc.capturedLines)
                        proc.capturedLines = []
                    } else {
                        proc.capturedLines.push(line)
                    }
                }
            }
            onExited: {
                root.refreshing = false
                proc.destroy()
            }
        }
    }

    function refresh() {
        root.refreshing = true
        const p = root._refreshProcComponent.createObject(root)
        p.running = true
    }

    property bool addingEvent: false
    property string addEventError: ""

    property Component _addEventProcComponent: Component {
        Process {
            id: proc
            property string capturedStderr: ""
            stderr: SplitParser {
                splitMarker: "\n"
                onRead: line => proc.capturedStderr += line
            }
            onExited: exitCode => {
                root.addingEvent = false
                if (exitCode !== 0) {
                    root.addEventError = proc.capturedStderr || "failed to add event"
                } else {
                    root.addEventError = ""
                    root.refresh()
                }
                proc.destroy()
            }
        }
    }

    function addEvent(title, when, durationMinutes) {
        root.addEventError = ""
        root.addingEvent = true
        const p = root._addEventProcComponent.createObject(root, {
            command: ["bash", root._scriptsDir + "/add-calendar-event.sh", title, when, String(durationMinutes)]
        })
        p.running = true
    }
}
