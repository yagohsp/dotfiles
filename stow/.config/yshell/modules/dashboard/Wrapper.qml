pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
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
            implicitWidth: dash.implicitWidth + padding * 2
            implicitHeight: dash.implicitHeight + padding * 2

            readonly property int padding: Tokens.padding.large

            Dash {
                id: dash

                anchors.fill: parent
                anchors.margins: parent.padding
                screenState: root.screenState
            }
        }
    }
}
