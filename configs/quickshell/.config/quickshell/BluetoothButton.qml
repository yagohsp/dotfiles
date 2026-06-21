import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

Rectangle {
    id: root
    visible: Bluetooth.defaultAdapter !== null
    implicitWidth: visible ? row.implicitWidth + 20 : 0
    implicitHeight: 36
    color: ma.pressed ? Theme.highlightMed
         : ma.containsMouse ? Theme.highlightLow
         : "transparent"
    radius: 4
    border.color: ma.containsMouse ? Theme.highlightMed : "transparent"
    border.width: 1

    readonly property var connectedDevice: [...Bluetooth.devices.values].find(d => d.connected) ?? null

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: ""
            font.family: Theme.font
            font.pixelSize: 16
            color: Theme.iris
        }

        Text {
            text: !(Bluetooth.defaultAdapter?.enabled ?? false) ? "Off"
                : root.connectedDevice ? root.connectedDevice.name
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
        onContainsMouseChanged: ShellGlobals.bluetoothHover.buttonHovered = containsMouse
    }
}
