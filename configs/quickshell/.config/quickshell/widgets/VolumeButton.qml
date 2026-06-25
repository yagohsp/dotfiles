import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + 40
    implicitHeight: 36
    color: "transparent"
    radius: 4

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "󰕾"
            font.family: Theme.font
            font.pixelSize: 22
            color: Theme.iris
        }

        Repeater {
            model: AudioService.outputDevices.filter(o => o.is_default)
            Text {
                required property var modelData
                text: `${modelData.volume}%`
                font.family: Theme.font
                font.pixelSize: 15
                color: Theme.subtle
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onContainsMouseChanged: {
            if (containsMouse) ShellGlobals.volumeModalCentered = false
            ShellGlobals.volumeHover.buttonHovered = containsMouse
        }
    }
}
