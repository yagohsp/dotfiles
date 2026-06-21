import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    readonly property int bodyWidth: 300
    readonly property int flareMargin: 58
    anchor.rect.x: Math.max(8, Math.min(ShellGlobals.bluetoothButtonCenterX - bodyWidth / 2 - flareMargin, (ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth - 8))
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 2
    implicitWidth: bodyWidth + flareMargin * 2
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: root.adapter?.enabled ?? false
    readonly property var devices: root.enabled
        ? [...Bluetooth.devices.values].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name)).slice(0, 8)
        : []

    RevealBox {
        id: revealBox
        open: ShellGlobals.bluetoothModalOpen
        color: Theme.base
        flareMargin: root.flareMargin
        bodyWidth: root.bodyWidth
        borderWidth: 2
        borderColor: Theme.iris

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Bluetooth"
                font.family: Theme.font; font.pixelSize: 14; font.bold: true
                color: Theme.text
                Layout.fillWidth: true
            }

            Text {
                text: root.adapter?.discovering ? "Scanning…" : "Scan"
                font.family: Theme.font; font.pixelSize: 11
                color: Theme.subtle
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: root.adapter !== null && !root.adapter.discovering
                    onClicked: root.adapter.discovering = true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Rectangle {
                implicitWidth: 36; implicitHeight: 20
                radius: 10
                color: root.enabled ? Theme.iris : Theme.highlightMed
                Rectangle {
                    x: root.enabled ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 8
                    color: Theme.text
                    Behavior on x { NumberAnimation { duration: 120 } }
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: root.adapter !== null
                    onClicked: root.adapter.enabled = !root.adapter.enabled
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }

        Repeater {
            model: ScriptModel { values: root.devices }

            RowLayout {
                id: devRow
                required property var modelData
                readonly property bool loading: devRow.modelData.state === BluetoothDeviceState.Connecting || devRow.modelData.state === BluetoothDeviceState.Disconnecting
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: ""
                    font.family: Theme.font; font.pixelSize: 13
                    color: devRow.modelData.connected ? Theme.iris : Theme.subtle
                }

                Text {
                    text: devRow.modelData.name
                    font.family: Theme.font; font.pixelSize: 13
                    font.bold: devRow.modelData.connected
                    color: devRow.modelData.connected ? Theme.iris : Theme.text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: devRow.loading
                    text: devRow.modelData.state === BluetoothDeviceState.Connecting ? "Connecting…" : "Disconnecting…"
                    font.family: Theme.font; font.pixelSize: 11
                    color: Theme.subtle
                }

                Text {
                    visible: !devRow.loading
                    text: devRow.modelData.connected ? "Disconnect" : "Connect"
                    font.family: Theme.font; font.pixelSize: 11
                    color: devRow.modelData.connected ? Theme.love : Theme.foam
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: devRow.modelData.connected ? devRow.modelData.disconnect() : devRow.modelData.connect()
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Text {
                    visible: devRow.modelData.bonded && !devRow.loading
                    text: "✕"
                    font.pixelSize: 11
                    color: Theme.muted
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: devRow.modelData.forget()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        Text {
            visible: root.enabled && root.devices.length === 0
            text: "No devices found"
            font.family: Theme.font; font.pixelSize: 12
            color: Theme.muted
            Layout.alignment: Qt.AlignHCenter
        }
    }

    CloseOnExit {
        anchors.fill: revealBox
        hover: ShellGlobals.bluetoothHover
    }

    Binding { target: ShellGlobals; property: "bluetoothActive"; value: revealBox.active }
}
