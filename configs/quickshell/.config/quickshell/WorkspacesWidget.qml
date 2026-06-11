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

            width:  ws.active ? 30 : 12
            height: 12
            radius: 4
            color:  ws.active   ? Theme.iris
                  : ws.occupied ? Theme.subtle
                  :               Theme.muted

            anchors.verticalCenter: parent.verticalCenter

            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
                    p.command = ["i3-msg", "workspace", "number", String(root.wsFiltered[modelData]?.id)]
                    p.running = true
                }
            }
        }
    }
}
