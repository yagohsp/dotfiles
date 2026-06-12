import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: (ShellGlobals.primaryBarWindow?.width ?? 1920) - 360 - 8
    anchor.rect.y: ShellGlobals.primaryBarWindow?.height ?? 44
    implicitWidth: 360
    implicitHeight: contentRect.implicitHeight
    color: "transparent"
    grabFocus: false

    mask: Region {
        width:  ShellGlobals.volumeModalOpen ? root.implicitWidth  : 0
        height: ShellGlobals.volumeModalOpen ? root.implicitHeight : 0
    }

    Rectangle {
        id: contentRect
        anchors.fill: parent
        implicitHeight: contentCol.implicitHeight + 28 + 2
        color: Theme.overlay
        border.color: Theme.highlightMed
        border.width: 1
        opacity: ShellGlobals.volumeModalOpen ? 1 : 0
        scale:   ShellGlobals.volumeModalOpen ? 1 : 0.96
        transformOrigin: Item.Top
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        ColumnLayout {
            id: contentCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: AudioService.outputDevices

                    ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: modelData.display_name
                                font.family: Theme.font; font.pixelSize: 13; font.bold: true
                                color: Theme.text; Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            RowLayout {
                                spacing: 6
                                MuteButton {
                                    muted: modelData.muted
                                    onToggle: AudioService.toggleOutputMute(modelData.sink_name)
                                }
                                Text {
                                    text: `${Math.round(outSlider.value)}%`
                                    font.family: Theme.font; font.pixelSize: 12; color: Theme.subtle
                                    Layout.minimumWidth: 36
                                }
                            }

                            VolumeSlider {
                                id: outSlider
                                Layout.fillWidth: true
                                inputValue: modelData.volume
                                onMoved: AudioService.setOutputVolume(modelData.sink_name, value)
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Default output"
                    font.family: Theme.font; font.pixelSize: 12; font.bold: true
                    color: Theme.rose; font.letterSpacing: 1
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: AudioService.defaultSinkOptions

                        OutputButton {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            label: modelData.display_name
                            active: modelData.is_default
                            onClicked: AudioService.setDefaultSink(modelData.sink_name)
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: AudioService.streamRoutes

                    ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            font.family: Theme.font; font.pixelSize: 14; font.bold: true
                            color: Theme.text; elide: Text.ElideRight; Layout.maximumWidth: 320
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            RowLayout {
                                spacing: 6
                                MuteButton {
                                    muted: modelData.muted
                                    onToggle: AudioService.toggleStreamMute(modelData.index)
                                }
                                Text {
                                    text: `${Math.round(streamSlider.value)}%`
                                    font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                                    Layout.minimumWidth: 36
                                }
                            }

                            VolumeSlider {
                                id: streamSlider
                                Layout.fillWidth: true
                                inputValue: modelData.volume
                                onMoved: AudioService.setStreamVolume(modelData.index, value)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            OutputButton {
                                visible: modelData.output_1_name !== ""
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                label: modelData.output_1_button_label
                                active: modelData.output_1_current
                                onClicked: AudioService.setStreamOutput(modelData.index, modelData.output_1_sink_name)
                            }
                            OutputButton {
                                visible: modelData.output_2_name !== ""
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                label: modelData.output_2_button_label
                                active: modelData.output_2_current
                                onClicked: AudioService.setStreamOutput(modelData.index, modelData.output_2_sink_name)
                            }
                            OutputButton {
                                visible: modelData.output_3_name !== ""
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                label: modelData.output_3_button_label
                                active: modelData.output_3_current
                                onClicked: AudioService.setStreamOutput(modelData.index, modelData.output_3_sink_name)
                            }
                            OutputButton {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                label: "Default"
                                active: modelData.following_default
                                onClicked: AudioService.setStreamOutputDefault(modelData.index)
                            }
                        }
                    }
                }
            }
        }
    }
}
