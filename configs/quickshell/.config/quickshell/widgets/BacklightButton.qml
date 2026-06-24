import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    visible: BrightnessService.available
    implicitWidth: visible ? row.implicitWidth + 40 : 0
    implicitHeight: 36
    color: "transparent"
    radius: 4

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "󰃟"
            font.family: Theme.font
            font.pixelSize: 22
            color: Theme.iris
        }

        Text {
            text: `${BrightnessService.brightness}%`
            font.family: Theme.font
            font.pixelSize: 15
            color: Theme.subtle
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onContainsMouseChanged: ShellGlobals.backlightHover.buttonHovered = containsMouse
    }
}
