import QtQuick
import Quickshell.Services.SystemTray

Row {
    spacing: 8
    leftPadding: 8
    rightPadding: 8

    Repeater {
        model: SystemTray.items

        Item {
            required property SystemTrayItem modelData
            width: 16
            height: 36

            Image {
                anchors.centerIn: parent
                source: modelData.icon?.toString() ?? ""
                sourceSize: Qt.size(16, 16)
                width: 16; height: 16
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        modelData.secondaryActivate(mouse.x, mouse.y)
                    else
                        modelData.activate(mouse.x, mouse.y)
                }
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
