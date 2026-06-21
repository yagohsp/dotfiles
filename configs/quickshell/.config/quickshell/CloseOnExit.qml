import QtQuick

MouseArea {
    required property var hover

    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    onEntered: hover.popupHovered = true
    onExited: hover.popupHovered = false
}
