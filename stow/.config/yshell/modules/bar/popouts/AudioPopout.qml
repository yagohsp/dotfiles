pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import YshellLight.Config
import qs.components
import qs.services
import qs.utils

// Device volumes, the default output and per-app volume and routing.
Item {
    id: root

    required property PopoutState popouts

    readonly property int maxHeight: 640

    implicitWidth: 420
    implicitHeight: Math.min(maxHeight, layout.implicitHeight + Tokens.padding.medium * 2)

    Component.onCompleted: AudioRoutes.peakWatchers++
    Component.onDestruction: AudioRoutes.peakWatchers--

    Flickable {
        anchors.fill: parent
        anchors.margins: Tokens.padding.medium
        clip: true
        contentHeight: layout.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: layout

            width: parent.width
            spacing: Tokens.spacing.medium

            Repeater {
                model: AudioRoutes.outputDevices

                ColumnLayout {
                    id: device

                    required property var modelData

                    Layout.fillWidth: true
                    spacing: 2

                    Heading {
                        text: device.modelData.display_name
                    }

                    VolumeRow {
                        volume: device.modelData.volume
                        muted: device.modelData.muted
                        onMoved: value => AudioRoutes.setOutputVolume(device.modelData.sink_name, value)
                        onMuteToggled: AudioRoutes.toggleOutputMute(device.modelData.sink_name)
                    }
                }
            }

            Divider {}

            Label {
                text: "Saída padrão"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                Repeater {
                    model: AudioRoutes.defaultSinkOptions

                    OutputButton {
                        required property var modelData

                        label: modelData.display_name
                        active: modelData.is_default
                        onClicked: AudioRoutes.setDefaultSink(modelData.sink_name)
                    }
                }
            }

            Divider {}

            Label {
                text: "Aplicativos"
            }

            StyledText {
                visible: AudioRoutes.streamRoutes.length === 0
                text: "Nenhum app tocando áudio"
                color: Colours.palette.m3onSurfaceVariant
            }

            Repeater {
                model: AudioRoutes.streamRoutes

                ColumnLayout {
                    id: stream

                    required property var modelData

                    readonly property string iconPath: Quickshell.iconPath(modelData.name.toLowerCase(), true)
                    readonly property var outputs: [1, 2, 3].map(n => ({
                                name: modelData[`output_${n}_name`],
                                label: modelData[`output_${n}_button_label`],
                                current: modelData[`output_${n}_current`],
                                sink: modelData[`output_${n}_sink_name`]
                            })).filter(o => o.name)

                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.small

                        Image {
                            visible: stream.iconPath.length > 0
                            source: stream.iconPath
                            sourceSize: Qt.size(18, 18)
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                        }

                        Heading {
                            text: stream.modelData.name
                        }
                    }

                    VolumeRow {
                        volume: stream.modelData.volume
                        muted: stream.modelData.muted
                        peak: AudioRoutes.streamPeak(stream.modelData.index)
                        onMoved: value => AudioRoutes.setStreamVolume(stream.modelData.index, value)
                        onMuteToggled: AudioRoutes.toggleStreamMute(stream.modelData.index)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.small

                        Repeater {
                            model: stream.outputs

                            OutputButton {
                                required property var modelData

                                label: modelData.label
                                active: modelData.current
                                onClicked: AudioRoutes.setStreamOutput(stream.modelData.index, modelData.sink)
                            }
                        }

                        OutputButton {
                            label: "Padrão"
                            active: stream.modelData.following_default
                            onClicked: AudioRoutes.setStreamOutputDefault(stream.modelData.index)
                        }
                    }
                }
            }
        }
    }

    component Heading: StyledText {
        Layout.fillWidth: true
        elide: Text.ElideRight
        font.bold: true
    }

    component Label: StyledText {
        color: Colours.palette.m3onSurfaceVariant
        font.pixelSize: 12
        font.bold: true
    }

    component Divider: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Colours.palette.m3outlineVariant
    }

    component OutputButton: Rectangle {
        id: button

        required property string label
        required property bool active

        signal clicked

        Layout.fillWidth: true
        Layout.preferredWidth: 0
        implicitHeight: 28
        radius: 8
        color: active ? Colours.palette.m3primaryContainer : area.containsMouse ? Colours.palette.m3surfaceContainerHighest : Colours.palette.m3surfaceContainerHigh

        StyledText {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            text: button.label
            color: button.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            elide: Text.ElideRight
            font.pixelSize: 11
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            id: area

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component VolumeRow: RowLayout {
        id: row

        required property real volume
        required property bool muted
        property real peak: -1

        // Follows the system unless the pointer is holding it
        property real shown: volume
        property bool held

        signal moved(value: real)
        signal muteToggled

        function setTo(value: real): void {
            shown = Math.max(0, Math.min(100, value));
        }

        function wheelBy(delta: real): void {
            setTo(shown + delta);
            moved(shown);
        }

        onVolumeChanged: {
            if (!held)
                shown = volume;
        }

        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: Icons.getVolumeIcon(row.shown / 100, row.muted)
            color: row.muted ? Colours.palette.m3error : Colours.palette.m3onSurface
            font: Tokens.font.icon.medium

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: row.muteToggled()
            }
        }

        StyledText {
            Layout.preferredWidth: 36
            text: `${Math.round(row.shown)}%`
            color: Colours.palette.m3onSurfaceVariant
            font.pixelSize: 12
        }

        Item {
            id: slider

            Layout.fillWidth: true
            implicitHeight: 24

            Rectangle {
                id: track

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: row.peak >= 0 ? -4 : 0
                height: 6
                radius: 3
                color: Colours.palette.m3surfaceContainerHighest

                Rectangle {
                    width: parent.width * row.shown / 100
                    height: parent.height
                    radius: 3
                    color: Colours.palette.m3primary
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.max(0, Math.min(parent.width - width, parent.width * row.shown / 100 - width / 2))
                    width: 14
                    height: 14
                    radius: 7
                    color: Colours.palette.m3onSurface
                }
            }

            Rectangle {
                visible: row.peak >= 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: track.bottom
                anchors.topMargin: 5
                height: 3
                radius: 1.5
                color: Colours.palette.m3surfaceContainerHighest

                Rectangle {
                    width: parent.width * Math.min(1, row.peak * row.shown / 100)
                    height: parent.height
                    radius: 1.5
                    color: Colours.palette.m3tertiary

                    Behavior on width {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Timer {
                id: throttle

                interval: 40
                repeat: true
                onTriggered: row.moved(row.shown)
            }

            MouseArea {
                anchors.fill: parent
                preventStealing: true
                cursorShape: Qt.PointingHandCursor
                onPressed: event => {
                    row.held = true;
                    AudioRoutes.dragging = true;
                    row.setTo(event.x / width * 100);
                    throttle.start();
                }
                onPositionChanged: event => row.setTo(event.x / width * 100)
                onReleased: event => {
                    throttle.stop();
                    row.setTo(event.x / width * 100);
                    row.moved(row.shown);
                    row.held = false;
                    AudioRoutes.dragging = false;
                }
                onWheel: event => row.wheelBy(event.angleDelta.y > 0 ? 2 : -2)
            }
        }
    }
}
