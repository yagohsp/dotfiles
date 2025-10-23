import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire

PanelWindow {
    color: "transparent"
    anchors {
        top: true
        right: true
    }
    margins {
        top: 15
        right: 15
    }

    width: 300
    implicitHeight: 500

    Rectangle {
        color: "tomato"

        anchors.fill: parent
        radius: 5

        ScrollView {
            id: scroll
            anchors.fill: parent
            anchors.margins: 12

            ColumnLayout {
                id: column
                width: scroll.width

                PwNodeLinkTracker {
                    id: linkTracker
                    node: Pipewire.defaultAudioSink
                }

                Repeater {
                    model: linkTracker.linkGroups

                    MixerItem {
                        required property PwLinkGroup modelData
                        node: modelData.source
                    }
                }
            }
        }
    }
}
