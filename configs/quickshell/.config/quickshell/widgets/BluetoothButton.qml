import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import ".."

Rectangle {
    id: root
    visible: Bluetooth.defaultAdapter !== null
    implicitWidth: visible ? row.implicitWidth + 20 : 0
    implicitHeight: 36
    color: "transparent"
    radius: 4

    readonly property var connectedDevice: [...Bluetooth.devices.values].find(d => d.connected) ?? null

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: !(Bluetooth.defaultAdapter?.enabled ?? false) ? "󰂲"
                : root.connectedDevice ? "󰂱"
                : "󰂯"
            font.family: Theme.font
            font.pixelSize: 16
            color: root.connectedDevice ? Theme.iris : Theme.subtle
        }

        Text {
            visible: text !== ""
            text: root.connectedDevice ? root.connectedDevice.name : ""
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
        cursorShape: Qt.ArrowCursor
        onContainsMouseChanged: ShellGlobals.bluetoothHover.buttonHovered = containsMouse
    }
}
