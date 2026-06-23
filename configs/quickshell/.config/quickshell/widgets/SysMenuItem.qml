import QtQuick
import ".."

Rectangle {
    id: root
    property string label: ""
    property bool danger: false
    signal clicked

    implicitWidth: 200
    implicitHeight: lbl.implicitHeight + 24
    color: ma.pressed ? Theme.highlightHigh
         : hover.hovered ? Theme.highlightMed
         : "transparent"
    radius: 4

    HoverHandler {
        id: hover
    }

    Text {
        id: lbl
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 16 }
        text: root.label
        font.family: Theme.font
        font.pixelSize: 14
        color: root.danger ? Theme.love : Theme.text
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
