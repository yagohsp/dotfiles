import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

PopupWindow {
    id: root
    // Window stays fixed-size and just snaps open/closed — animating real
    // X11 window geometry every frame caused visible flicker (native resize
    // isn't double-buffered the way compositor-side clipping is). RevealBox
    // does the actual grow/shrink animation as an in-process clip.
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    // Window is wider than the body (bodyWidth + flareMargin*2) so the top
    // corners have real canvas to flare outward into -- see RevealBox's
    // flareMargin doc. Center the BODY on the button, not the wider window.
    readonly property int bodyWidth: 320
    // Must stay comfortably larger than RevealBox's topRadius/joinSmoothing,
    // or the corner's curve wants more canvas than exists and gets clipped/
    // inverted at the window edge instead of flaring smoothly.
    readonly property int flareMargin: 58
    anchor.rect.x: Math.max(8, Math.min(ShellGlobals.wifiButtonCenterX - bodyWidth / 2 - flareMargin, (ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth - 8))
    // Overlap by exactly the popup's own border width so its top border
    // ring lands on the same pixels as the bar's bottom border, merging
    // into one line instead of two adjacent parallel ones.
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
        joinHeightScale: 1

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
                                // Ask for the password up front instead of
                                // attempting a blind passwordless connect:
                                // that attempt tears down the current
                                // connection, fails, and NetworkManager's
                                // autoconnect snaps back to it before this
                                // prompt would ever get a chance to show.
                                // Networks with a saved profile already have
                                // a cached secret, so they skip straight to
                                // connect() below.
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
        // Don't close mid-connection-attempt — nmcli can take a few
        // seconds, and the mouse drifting off the popup during that wait
        // would otherwise hide the password prompt before it ever shows.
        anchors.fill: revealBox
        onExited: if (!WifiService.connecting) ShellGlobals.wifiModalOpen = false
    }
}
