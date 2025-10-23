import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick

PanelWindow {
    id: topbar
    implicitHeight: 30
    color: "#666093"

    anchors {
        top: true
        left: true
        right: true
    }

    // Modal {
    //     id: modal
    // }

    Mixer {
        id: mixer
        visible: true
    }

    RowLayout {
        anchors.fill: parent
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 50
            color: "tomato"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mixer.visible = !mixer.visible;
                }
            }
        }
    }
}
