pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import YshellLight.Config
import qs.components

// Drops from the strip under the centre island. Open while the pointer is over either.
Item {
    id: root

    required property ScreenState screenState

    readonly property bool shouldBeActive: screenState.dashboard && Config.dashboard.enabled
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        active: root.shouldBeActive || root.visible

        sourceComponent: Item {
            implicitWidth: column.implicitWidth + padding * 2
            implicitHeight: column.implicitHeight + padding * 2

            readonly property int padding: Tokens.padding.large

            ColumnLayout {
                id: column

                anchors.fill: parent
                anchors.margins: parent.padding
                spacing: Tokens.spacing.medium

                Dash {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    screenState: root.screenState
                }

                ThemePicker {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
