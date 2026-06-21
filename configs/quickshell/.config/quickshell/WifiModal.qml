import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    readonly property int bodyWidth: 320
    readonly property int flareMargin: 58
    anchor.rect.x: Math.max(8, Math.min(ShellGlobals.wifiButtonCenterX - bodyWidth / 2 - flareMargin, (ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth - 8))
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 2
    implicitWidth: bodyWidth + flareMargin * 2
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    property string pendingSsid: ""

    onVisibleChanged: if (!visible) root.pendingSsid = ""

    Connections {
        target: WifiService
        function onConnectErrorChanged() {
            if (WifiService.connectError !== "needs-password") root.pendingSsid = ""
        }
    }

    RevealBox {
        id: revealBox
        open: ShellGlobals.wifiModalOpen
        color: Theme.base
        flareMargin: root.flareMargin
        bodyWidth: root.bodyWidth
        borderWidth: 2
        borderColor: Theme.iris

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Wi-Fi"
                font.family: Theme.font; font.pixelSize: 14; font.bold: true
                color: Theme.text
                Layout.fillWidth: true
            }

            Text {
                text: WifiService.scanning ? "Scanning…" : "Rescan"
                font.family: Theme.font; font.pixelSize: 11
                color: Theme.subtle
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: !WifiService.scanning
                    onClicked: WifiService.rescan()
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Rectangle {
                implicitWidth: 36; implicitHeight: 20
                radius: 10
                color: WifiService.radioEnabled ? Theme.iris : Theme.highlightMed
                Rectangle {
                    x: WifiService.radioEnabled ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 8
                    color: Theme.text
                    Behavior on x { NumberAnimation { duration: 120 } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: WifiService.toggleRadio()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }

        Repeater {
            model: WifiService.radioEnabled ? WifiService.networks : []

            ColumnLayout {
                id: netRow
                required property var modelData
                Layout.fillWidth: true
                spacing: 6

                Item {
                    Layout.fillWidth: true
                    implicitHeight: rowLayout.implicitHeight

                    MouseArea {
                        anchors.fill: parent
                        enabled: !netRow.modelData.active
                        onClicked: {
                            root.pendingSsid = netRow.modelData.ssid
                            if (netRow.modelData.security && !WifiService.hasSavedProfile(netRow.modelData.ssid)) {
                                WifiService.connectError = "needs-password"
                            } else {
                                WifiService.connect(netRow.modelData.ssid)
                            }
                        }
                        cursorShape: Qt.PointingHandCursor
                    }

                    RowLayout {
                        id: rowLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 8

                        Text {
                            text: netRow.modelData.security ? "🔒" : "📶"
                            font.pixelSize: 12
                            color: netRow.modelData.active ? Theme.iris : Theme.subtle
                        }

                        Text {
                            text: netRow.modelData.ssid
                            font.family: Theme.font; font.pixelSize: 13
                            font.bold: netRow.modelData.active
                            color: netRow.modelData.active ? Theme.iris : Theme.text
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: `${netRow.modelData.signal}%`
                            font.family: Theme.font; font.pixelSize: 11
                            color: Theme.subtle
                        }

                        Text {
                            visible: netRow.modelData.active
                            text: "✕"
                            font.pixelSize: 11
                            color: Theme.love
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                onClicked: WifiService.disconnect()
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                RowLayout {
                    visible: root.pendingSsid === netRow.modelData.ssid && WifiService.connectError === "needs-password"
                    Layout.fillWidth: true
                    spacing: 6

                    TextInput {
                        id: pwInput
                        Layout.fillWidth: true
                        font.family: Theme.font; font.pixelSize: 12
                        color: Theme.text
                        echoMode: TextInput.Password
                        Keys.onReturnPressed: {
                            WifiService.connect(netRow.modelData.ssid, pwInput.text)
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -4
                            z: -1
                            color: Theme.highlightLow
                            radius: 2
                        }
                    }

                    Text {
                        text: "Connect"
                        font.family: Theme.font; font.pixelSize: 11
                        color: Theme.foam
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: WifiService.connect(netRow.modelData.ssid, pwInput.text)
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }

        Text {
            visible: WifiService.radioEnabled && WifiService.networks.length === 0
            text: "No networks found"
            font.family: Theme.font; font.pixelSize: 12
            color: Theme.muted
            Layout.alignment: Qt.AlignHCenter
        }
    }

    CloseOnExit {
        anchors.fill: revealBox
        hover: ShellGlobals.wifiHover
    }

    Binding {
        target: ShellGlobals.wifiHover
        property: "suppressClose"
        value: WifiService.connecting
    }

    Binding { target: ShellGlobals; property: "wifiActive"; value: revealBox.active }
}
