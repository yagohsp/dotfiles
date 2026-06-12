import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: 20
    anchor.rect.y: ShellGlobals.primaryBarWindow?.height ?? 64
    implicitWidth:  220
    implicitHeight: 68
    color: "transparent"
    grabFocus: false

    mask: Region {
        width:  root._open ? 220 : 0
        height: root._open ? 68  : 0
    }

    property bool _open: false
    property int  volumeValue: 0
    property bool isMuted: false

    Timer {
        id: hideTimer
        interval: 1400
        onTriggered: root._open = false
    }

    function show(vol, muted) {
        root.volumeValue = vol
        root.isMuted     = muted
        root._open       = true
        hideTimer.restart()
    }

    Process {
        command: ["bash", "-c",
            "[ -p /tmp/qs-osd ] || mkfifo /tmp/qs-osd; while true; do cat /tmp/qs-osd; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.trim().split(":")
                if (parts.length >= 2)
                    root.show(parseInt(parts[0]) || 0, parts[1] === "true")
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.overlay
        radius: 8
        opacity: root._open ? 1 : 0
        scale:   root._open ? 1 : 0.96
        transformOrigin: Item.TopLeft
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 12

            Text {
                text: root.isMuted ? "󰝟" : "󰕾"
                font.family: Theme.font
                font.pixelSize: 22
                color: Theme.foam
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: root.isMuted ? "Muted" : `${root.volumeValue}%`
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Theme.text
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Theme.highlightMed

                    Rectangle {
                        width: parent.width * (root.isMuted ? 0 : root.volumeValue / 100)
                        height: parent.height
                        radius: 3
                        color: Theme.foam
                    }
                }
            }
        }
    }
}
