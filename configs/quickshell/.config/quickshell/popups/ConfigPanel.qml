import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import ".."

PopupWindow {
    id: root
    readonly property int _w: 560
    readonly property int _h: 360
    readonly property int _fadeDuration: 180

    readonly property var _tabs: ["Monitors"]
    property string _activeTab: "Monitors"

    // Stays mapped only while open or fading out, so the fade-out animation
    // is visible before the window unmaps.
    property bool _mapped: false
    visible: ShellGlobals.primaryBarWindow !== null && root._mapped

    Connections {
        target: ShellGlobals
        function onConfigPanelOpenChanged() {
            if (ShellGlobals.configPanelOpen) root._mapped = true
            else unmapTimer.restart()
        }
    }

    Timer {
        id: unmapTimer
        interval: root._fadeDuration
        onTriggered: root._mapped = false
    }

    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: ((ShellGlobals.primaryBarWindow?.width ?? 1920) - _w) / 2
    anchor.rect.y: (Screen.height - _h) / 2
    implicitWidth: _w
    implicitHeight: _h
    color: "transparent"
    grabFocus: false

    Rectangle {
        anchors.fill: parent
        color: Theme.overlay
        radius: 8
        border.width: 2
        border.color: Theme.iris

        opacity: ShellGlobals.configPanelOpen ? 1 : 0
        scale:   ShellGlobals.configPanelOpen ? 1 : 0.96
        transformOrigin: Item.Center
        Behavior on opacity { NumberAnimation { duration: root._fadeDuration; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: root._fadeDuration; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "Settings"
                    font.family: Theme.font; font.pixelSize: 14; font.bold: true; color: Theme.text
                }

                Rectangle {
                    implicitWidth: closeLbl.implicitWidth + 16; implicitHeight: closeLbl.implicitHeight + 8
                    radius: 2
                    color: closeMa.pressed ? Theme.highlightMed : Theme.highlightLow
                    Text {
                        id: closeLbl; anchors.centerIn: parent; text: "Close"
                        font.family: Theme.font; font.pixelSize: 12; color: Theme.foam
                    }
                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellGlobals.configPanelOpen = false
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                ColumnLayout {
                    Layout.preferredWidth: 120
                    Layout.maximumWidth: 120
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    spacing: 4

                    Repeater {
                        model: root._tabs

                        Rectangle {
                            required property string modelData
                            readonly property bool active: root._activeTab === modelData
                            Layout.fillWidth: true
                            implicitHeight: 30
                            radius: 4
                            color: active ? Theme.highlightMed : (tabMa.containsMouse ? Theme.highlightLow : "transparent")

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.modelData
                                font.family: Theme.font; font.pixelSize: 12
                                color: parent.active ? Theme.text : Theme.subtle
                            }

                            MouseArea {
                                id: tabMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._activeTab = parent.modelData
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                Rectangle { Layout.fillHeight: true; implicitWidth: 1; color: Theme.highlightMed }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: tabLoader.item ? tabLoader.item.implicitHeight : 0
                    clip: true

                    Loader {
                        id: tabLoader
                        width: parent.width
                        sourceComponent: root._activeTab === "Monitors" ? monitorsTabComponent : null
                    }
                }
            }
        }
    }

    Component { id: monitorsTabComponent; MonitorsTab {} }
}
