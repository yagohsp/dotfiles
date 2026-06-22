import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
    width: parent.width
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
