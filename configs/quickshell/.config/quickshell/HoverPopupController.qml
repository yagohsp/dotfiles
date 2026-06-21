import QtQuick

Item {
    property bool buttonHovered: false
    property bool popupHovered: false
    property bool suppressClose: false

    readonly property bool hovering: buttonHovered || popupHovered
}
