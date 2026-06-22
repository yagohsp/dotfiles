import QtQuick
import ".."

Rectangle {
    id: root
    property string label: ""
    property bool danger: false
    signal clicked

    implicitWidth: lbl.implicitWidth + 16
    implicitHeight: 36
    color: ma.pressed ? Theme.highlightMed
         : ma.containsMouse ? Theme.highlightLow
         : Theme.surface
    radius: 4
    border.color: ma.containsMouse ? Theme.highlightMed : "transparent"
    border.width: 1


    Text {
        id: lbl
        anchors.centerIn: parent
        text: root.label
        font.family: Theme.font
        font.pixelSize: 12
        font.bold: true
        color: root.danger ? Theme.love : Theme.text
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
