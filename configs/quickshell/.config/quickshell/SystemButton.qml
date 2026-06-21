import QtQuick

Rectangle {
    id: root
    implicitWidth: lbl.implicitWidth + 20
    implicitHeight: 36
    color: ma.pressed ? Theme.highlightMed
         : ma.containsMouse ? Theme.highlightLow
         : "transparent"
    radius: 4
    border.color: ma.containsMouse ? Theme.highlightMed : "transparent"
    border.width: 1

    Text {
        id: lbl
        anchors.centerIn: parent
        text: "⏻"
        font.family: Theme.font
        font.pixelSize: 22
        color: Theme.iris
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: ShellGlobals.systemHover.buttonHovered = containsMouse
    }
}
