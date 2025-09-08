import Quickshell
import QtQuick

PanelWindow {
    id: modal
    visible: false
    color: Qt.rgba(0, 50, 50, 0.1)

    MouseArea {
        anchors.fill: parent
        onClicked: {
            modal.visible = false;
        }
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
}
