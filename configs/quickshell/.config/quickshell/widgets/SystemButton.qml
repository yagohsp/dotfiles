import QtQuick
import ".."

Rectangle {
    id: root
    implicitWidth: lbl.implicitWidth + 20
    implicitHeight: 36
    color: "transparent"
    radius: 4

    Text {
        id: lbl
        anchors.centerIn: parent
        text: "⏻"
        font.family: Theme.font
        font.pixelSize: 22
        color: Theme.iris
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onContainsMouseChanged: ShellGlobals.systemHover.buttonHovered = containsMouse
    }
}
