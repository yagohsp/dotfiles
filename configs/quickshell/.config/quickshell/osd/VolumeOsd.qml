import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import ".."

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: ((ShellGlobals.primaryBarWindow?.width ?? 1920) - 220) / 2
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) + 8
    implicitWidth:  220
    implicitHeight: 44
    color: "transparent"
    grabFocus: false

    mask: Region {
        width:  root._open ? 220 : 0
        height: root._open ? 44  : 0
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
        radius: 10
        opacity: root._open ? 1 : 0
        scale:   root._open ? 1 : 0.96
        transformOrigin: Item.Top
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 8; bottomMargin: 8 }
            spacing: 10

            Text {
                text: root.isMuted ? "󰝟" : "󰕾"
                font.family: Theme.font
                font.pixelSize: 20
                color: root.isMuted ? Theme.muted : Theme.foam
            }

            Rectangle {
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: Theme.highlightMed

                Rectangle {
                    width: parent.width * (root.isMuted ? 0 : root.volumeValue / 100)
                    height: parent.height
                    radius: 5
                    color: root.isMuted ? Theme.muted : Theme.foam
                    Behavior on width { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                }
            }

            Text {
                text: root.isMuted ? "Muted" : `${root.volumeValue}%`
                font.family: Theme.font
                font.pixelSize: 12
                font.bold: true
                color: Theme.text
            }
        }
    }
}
