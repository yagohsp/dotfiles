import QtQuick
import ".."

Rectangle {
    id: root
    property string label: ""
    signal clicked

    implicitWidth: 200
    implicitHeight: lbl.implicitHeight + 24
    color: ma.pressed ? Theme.highlightMed : "transparent"
    radius: 2


    Text {
        id: lbl
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 16 }
        text: root.label
        font.family: Theme.font
        font.pixelSize: 14
        color: Theme.text
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
