import QtQuick
import Quickshell.Io

Row {
    id: root
    required property string monitorName
    spacing: 6

    property var wsFiltered: WorkspaceService.workspaces.filter(w => w.monitor === root.monitorName)

    Repeater {
        model: root.wsFiltered.length

        Rectangle {
            required property int modelData

            property var ws: root.wsFiltered[modelData] ?? {}
            property var icons: ws.icons ?? []

            width: icons.length > 0
                   ? Math.max(46, icons.length * 24 + 10)
                   : (ws.active ? 46 : 32)
            height: 30
            radius: 6
            color: ws.active   ? Theme.iris
                 : ws.occupied ? Theme.subtle
                 :               Theme.muted

            anchors.verticalCenter: parent.verticalCenter

            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Row {
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: icons

                    Image {
                        required property string modelData
                        source: modelData
                        sourceSize: Qt.size(20, 20)
                        width: 20
                        height: 20
                        smooth: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
                    p.command = ["i3-msg", "workspace", String(root.wsFiltered[modelData]?.name)]
                    p.running = true
                }
            }
        }
    }
}
