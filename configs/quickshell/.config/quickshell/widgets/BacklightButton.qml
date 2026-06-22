import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    visible: BrightnessService.available
    implicitWidth: visible ? row.implicitWidth + 20 : 0
    implicitHeight: 36
    color: ma.pressed ? Theme.highlightMed
         : ma.containsMouse ? Theme.highlightLow
         : "transparent"
    radius: 4
    border.color: ma.containsMouse ? Theme.highlightMed : "transparent"
    border.width: 1

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
        onContainsMouseChanged: ShellGlobals.backlightHover.buttonHovered = containsMouse
    }
}
