import QtQuick

Rectangle {
    id: root
    property bool muted: false
    signal toggle

    implicitWidth: lbl.implicitWidth + 12
    implicitHeight: lbl.implicitHeight + 4
    color: ma.pressed ? Theme.highlightMed : "transparent"
    radius: 2

    Text {
        id: lbl
        anchors.centerIn: parent
        text: root.muted ? "󰝟" : "󰕾"
        font.family: Theme.font
        font.pixelSize: 18
        color: root.muted ? Theme.love : Theme.rose
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        onClicked: root.toggle()
        cursorShape: Qt.PointingHandCursor
    }
}
