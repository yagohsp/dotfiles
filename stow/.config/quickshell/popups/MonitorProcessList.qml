import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 8

    property var processes: []
    property string metricKey: "cpu"
    property color accentColor: Theme.iris
    property string killError: ""

    property string listMode: "unique"
    readonly property int _displayLimit: 5

    signal killPid(int pid)
    signal killPids(var pids)

    function _metricValue(proc) {
        return proc[root.metricKey] || 0
    }

    function _grouped(items) {
        const groups = {}
        for (let i = 0; i < items.length; i++) {
            const proc = items[i]
            const name = proc.name || "?"
            if (!groups[name])
                groups[name] = { name: name, value: 0, pids: [] }
            groups[name].value += root._metricValue(proc)
            groups[name].pids.push(proc.pid)
        }
        const list = []
        for (const name in groups) {
            if (!Object.prototype.hasOwnProperty.call(groups, name))
                continue
            list.push(groups[name])
        }
        list.sort((a, b) => b.value - a.value)
        return list.slice(0, root._displayLimit)
    }

    readonly property var displayItems: {
        const items = root.processes || []
        if (items.length === 0)
            return []
        if (root.listMode === "grouped")
            return root._grouped(items)
        return items.slice(0, root._displayLimit)
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Text {
            text: "Processes"
            font.family: Theme.font; font.pixelSize: 12
            font.bold: root.listMode === "unique"
            color: root.listMode === "unique" ? root.accentColor : Theme.subtle
            MouseArea {
                anchors.fill: parent; anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: root.listMode = "unique"
            }
        }

        Text {
            text: "By name"
            font.family: Theme.font; font.pixelSize: 12
            font.bold: root.listMode === "grouped"
            color: root.listMode === "grouped" ? root.accentColor : Theme.subtle
            MouseArea {
                anchors.fill: parent; anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: root.listMode = "grouped"
            }
        }

        Item { Layout.fillWidth: true }
    }

    Text {
        Layout.fillWidth: true
        visible: root.killError !== ""
        text: root.killError
        font.family: Theme.font; font.pixelSize: 11; color: Theme.love
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: root.displayItems

        ColumnLayout {
            required property var modelData
            Layout.fillWidth: true
            spacing: 0

            readonly property real metricValue: modelData.value !== undefined
                ? modelData.value
                : root._metricValue(modelData)

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 36

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    Text {
                        text: {
                            if (root.listMode === "grouped" && modelData.pids && modelData.pids.length > 1)
                                return `${modelData.name} (${modelData.pids.length})`
                            return modelData.name
                        }
                        font.family: Theme.font; font.pixelSize: 12; color: Theme.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: `${Math.round(metricValue * 10) / 10}%`
                        font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                        Layout.preferredWidth: 44
                        horizontalAlignment: Text.AlignRight
                    }

                    Rectangle {
                        implicitWidth: killLbl.implicitWidth + 12
                        implicitHeight: killLbl.implicitHeight + 6
                        radius: 2
                        color: killMa.pressed ? Theme.highlightMed : Theme.highlightLow
                        Text {
                            id: killLbl
                            anchors.centerIn: parent
                            text: "Kill"
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.love
                        }
                        MouseArea {
                            id: killMa
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.listMode === "grouped" && modelData.pids && modelData.pids.length > 0)
                                    root.killPids(modelData.pids)
                                else if (modelData.pid)
                                    root.killPid(modelData.pid)
                            }
                        }
                    }
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: root.displayItems.length === 0
        text: "No processes"
        font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
        horizontalAlignment: Text.AlignHCenter
    }
}
