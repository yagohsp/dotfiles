import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    readonly property int _titleWidth: 100
    readonly property int _pad: 32
    width: _titleWidth + _pad + 22
    implicitWidth: width
    implicitHeight: 36
    color: "transparent"
    radius: 4

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: _pad / 2
        anchors.rightMargin: _pad / 2
        spacing: 6

        Text {
            text: MusicService.active && !MusicService.paused ? "󰝚" : "󰝛"
            font.family: Theme.font
            font.pixelSize: 18
            color: MusicService.active ? Theme.iris : Theme.subtle
        }

        Text {
            Layout.fillWidth: true
            text: MusicService.title
            font.family: Theme.font
            font.pixelSize: 13
            color: Theme.subtle
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onContainsMouseChanged: ShellGlobals.musicHover.buttonHovered = containsMouse
        onClicked: MusicService.playPause()
    }
}
