import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

ColumnLayout {
    id: root
    spacing: 10

    property var monitors: []
    property var _selectedRate: ({})
    property bool _busy: false

    function refresh() {
        const p = root._listComponent.createObject(root)
        p.running = true
    }

    Component.onCompleted: root.refresh()

    property Component _listComponent: Component {
        Process {
            id: proc
            command: [Quickshell.env("HOME") + "/dotfiles/scripts/list-monitors.sh"]
            property string _out: ""
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: line => proc._out += line
            }
            onExited: exitCode => {
                try {
                    const parsed = JSON.parse(proc._out)
                    const rates = {}
                    for (const m of parsed)
                        rates[m.name] = root._selectedRate[m.name] ?? m.currentRate
                    root._selectedRate = rates
                    root.monitors = parsed
                } catch(_) {}
                proc.destroy()
            }
        }
    }

    property Component _setPrimaryComponent: Component {
        Process {
            id: proc
            onExited: exitCode => {
                root._busy = false
                root.refresh()
                proc.destroy()
            }
        }
    }

    function setPrimary(name) {
        root._busy = true
        const hz = root._selectedRate[name]
        const p = root._setPrimaryComponent.createObject(root, {
            command: [Quickshell.env("HOME") + "/dotfiles/scripts/set-primary-monitor.sh", name, String(hz)]
        })
        p.running = true
    }

    Text {
        text: "Monitors"
        font.family: Theme.font; font.pixelSize: 13; font.bold: true; color: Theme.text
    }

    Repeater {
        model: root.monitors

        ColumnLayout {
            id: monitorRow
            required property var modelData
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: modelData.name
                    font.family: Theme.font; font.pixelSize: 12; font.bold: true; color: Theme.text
                }

                Rectangle {
                    id: actionBtn
                    readonly property bool noop: modelData.primary && root._selectedRate[modelData.name] === modelData.currentRate
                    implicitWidth: setLbl.implicitWidth + 16; implicitHeight: setLbl.implicitHeight + 8
                    radius: 2
                    opacity: root._busy || actionBtn.noop ? 0.5 : 1
                    color: setMa.pressed ? Theme.highlightMed : Theme.highlightLow
                    Text {
                        id: setLbl; anchors.centerIn: parent
                        text: !modelData.primary ? "Set Primary" : (actionBtn.noop ? "Primary" : "Apply")
                        font.family: Theme.font; font.pixelSize: 11; color: Theme.foam
                    }
                    MouseArea {
                        id: setMa
                        anchors.fill: parent
                        enabled: !root._busy && !actionBtn.noop
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setPrimary(modelData.name)
                    }
                }
            }

            ComboBox {
                Layout.fillWidth: true
                model: monitorRow.modelData.rates.map(r => ({ value: r, label: r + " Hz" }))
                textRole: "label"
                currentIndex: monitorRow.modelData.rates.indexOf(root._selectedRate[monitorRow.modelData.name])
                onActivated: index => {
                    const r = root._selectedRate
                    r[monitorRow.modelData.name] = monitorRow.modelData.rates[index]
                    root._selectedRate = Object.assign({}, r)
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }
        }
    }
}
