import QtQuick
import QtQuick.Layouts

Rectangle {
    implicitWidth: row.implicitWidth + 20
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
        onClicked: ShellGlobals.volumeModalOpen = !ShellGlobals.volumeModalOpen
        cursorShape: Qt.PointingHandCursor
    }
}
