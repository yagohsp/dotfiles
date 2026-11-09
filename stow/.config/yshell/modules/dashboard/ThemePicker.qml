pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import YshellLight.Config
import qs.components
import qs.services

RowLayout {
    spacing: Tokens.spacing.small

    StyledText {
        text: "Tema"
        color: Colours.palette.m3onSurfaceVariant
        font.bold: true
    }

    Repeater {
        model: ThemeInfo.themes

        Rectangle {
            id: button

            required property var modelData
            readonly property bool active: modelData.name === ThemeInfo.name

            implicitWidth: content.implicitWidth + 20
            implicitHeight: 34
            radius: 10
            color: active ? Colours.palette.m3primaryContainer : area.containsMouse ? Colours.palette.m3surfaceContainerHigh : Colours.palette.m3surfaceContainer

            Row {
                id: content

                anchors.centerIn: parent
                spacing: 8

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Repeater {
                        model: button.modelData.colours

                        Rectangle {
                            required property string modelData

                            width: 12
                            height: 12
                            radius: 6
                            color: `#${modelData}`
                            border.width: 1
                            border.color: Colours.palette.m3outline
                        }
                    }
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: button.modelData.label
                    color: button.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
                    font.bold: button.active
                }
            }

            MouseArea {
                id: area

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ThemeInfo.apply(button.modelData.name)
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
