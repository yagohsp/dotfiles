import QtQuick
import ".."

Rectangle {
    id: root
    implicitWidth: lbl.implicitWidth + 40
    implicitHeight: 36
    color: "transparent"
    radius: 4

    Text {
        id: lbl
        anchors.centerIn: parent
        text: "󰒓"
        font.family: Theme.font
        font.pixelSize: 18
        color: Theme.iris
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellGlobals.configPanelOpen = true
    }
}
