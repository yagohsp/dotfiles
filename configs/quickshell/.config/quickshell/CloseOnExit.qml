import QtQuick

MouseArea {
    property var hover: null

    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    onEntered: if (hover) hover.popupHovered = true
    onExited: if (hover) hover.popupHovered = false
}
