import QtQuick
import Quickshell.Services.SystemTray
import ".."

Item {
    id: root
    implicitWidth: pill.implicitWidth + 20
    implicitHeight: 36

    Rectangle {
        id: pill
        anchors.centerIn: parent
        implicitWidth: row.implicitWidth + 12
        implicitHeight: 26
        color: Theme.highlightMed
        radius: 6

        HoverHandler {
            onHoveredChanged: ShellGlobals.trayHover.buttonHovered = hovered
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: SystemTray.items

                Item {
                    required property SystemTrayItem modelData
                    width: 24
                    height: 26

                    Image {
                        anchors.centerIn: parent
                        source: modelData.icon?.toString() ?? ""
                        sourceSize: Qt.size(16, 16)
                        width: 16; height: 16
                        smooth: true
                    }

                    HoverHandler {
                        id: iconHover
                        onHoveredChanged: {
                            if (hovered) {
                                ShellGlobals.trayMenuItem = modelData
                                const p = parent.mapToItem(null, parent.width / 2, parent.height)
                                ShellGlobals.trayMenuX = p.x
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onClicked: mouse => modelData.activate(mouse.x, mouse.y)
                        cursorShape: Qt.ArrowCursor
                    }
                }
            }
        }
    }
}
