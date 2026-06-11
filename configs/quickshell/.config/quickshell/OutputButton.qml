import QtQuick

Rectangle {
    id: root
    property string label: ""
    property bool active: false
    signal clicked

    implicitWidth: lbl.implicitWidth + 4
    implicitHeight: lbl.implicitHeight + 12
    color: active  ? Theme.iris
         : ma.pressed ? Theme.highlightMed
         : Theme.highlightLow
    border.color: active ? Theme.rose : "transparent"
    border.width: 1
    radius: 2


    Text {
        id: lbl
        anchors.centerIn: parent
        text: root.label
        font.family: Theme.font
        font.pixelSize: 10
        font.bold: true
        color: root.active ? Theme.base : Theme.text
        elide: Text.ElideRight
        maximumLineCount: 1
        horizontalAlignment: Text.AlignHCenter
        width: Math.min(implicitWidth, 90)
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
