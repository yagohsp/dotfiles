import QtQuick
import Quickshell.Bluetooth
import ".."

Rectangle {
    id: root
    visible: Bluetooth.defaultAdapter !== null
    implicitWidth: visible ? icon.implicitWidth + 40 : 0
    implicitHeight: 36
    color: "transparent"
    radius: 4

    readonly property var connectedDevice: [...Bluetooth.devices.values].find(d => d.connected) ?? null

    Text {
        id: icon
        anchors.centerIn: parent
        text: !(Bluetooth.defaultAdapter?.enabled ?? false) ? "󰂲"
            : root.connectedDevice ? "󰂱"
            : "󰂯"
        font.family: Theme.font
        font.pixelSize: 16
        color: root.connectedDevice ? Theme.iris : Theme.subtle
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onContainsMouseChanged: ShellGlobals.bluetoothHover.buttonHovered = containsMouse
    }
}
