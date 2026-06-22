import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    visible: WifiService.available
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
            text: ""
            font.family: Theme.font
            font.pixelSize: 16
            color: Theme.iris
        }

        Text {
            text: !WifiService.radioEnabled ? "Off"
                : WifiService.connected ? WifiService.activeSsid
                : "Disconnected"
            font.family: Theme.font
            font.pixelSize: 13
            color: Theme.subtle
            elide: Text.ElideRight
            Layout.maximumWidth: 140
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: ShellGlobals.wifiHover.buttonHovered = containsMouse
    }
}
