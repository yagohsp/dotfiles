import QtQuick
import ".."

Rectangle {
    id: root
    implicitWidth: icon.implicitWidth + 40
    implicitHeight: 36
    color: "transparent"
    radius: 4
    border.color: ShellGlobals.recordingMode !== "none" ? Theme.highlightMed : "transparent"
    border.width: 1

    Text {
        id: icon
        anchors.centerIn: parent
        text: "󰄀"
        font.family: Theme.font
        font.pixelSize: 20
        color: ShellGlobals.recordingMode !== "none" ? Theme.love : Theme.iris
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: ShellGlobals.captureHover.buttonHovered = containsMouse
        cursorShape: Qt.ArrowCursor
    }
}
