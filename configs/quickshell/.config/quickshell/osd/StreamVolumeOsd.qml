import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

PopupWindow {
    id: root
    // On X11, PopupWindow grabs input over its full mapped rect regardless of
    // mask (mask doesn't suppress input on this backend), and anchor.rect
    // position gets clamped back on-screen rather than truly hidden offscreen,
    // and resizing the window on every show() was too slow. So fully unmap
    // the window itself while idle - that's the only thing that reliably
    // removes its input grab on X11.
    visible: ShellGlobals.primaryBarWindow !== null && root._open
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: ((ShellGlobals.primaryBarWindow?.width ?? 1920) - 220) / 2
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) + 8
    implicitWidth:  220
    implicitHeight: 60
    color: "transparent"
    grabFocus: false

    property bool   _open: false
    property int    volumeValue: 0
    property bool   isMuted: false
    property string appName: ""

    Timer {
        id: hideTimer
        interval: 1400
        onTriggered: root._open = false
    }

    function show(name, vol, muted) {
        root.appName     = name
        root.volumeValue = vol
        root.isMuted     = muted
        root._open       = true
        hideTimer.restart()
    }

    Process {
        command: ["bash", "-c",
            "[ -p /tmp/qs-stream-osd ] || mkfifo /tmp/qs-stream-osd; while true; do cat /tmp/qs-stream-osd; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try {
                    const d = JSON.parse(data.trim())
                    root.show(d.name ?? "", d.volume ?? 0, d.muted ?? false)
                } catch(_) {}
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

        ColumnLayout {
            anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 8; bottomMargin: 8 }
            spacing: 6

            Text {
                text: root.appName
                font.family: Theme.font
                font.pixelSize: 11
                color: Theme.muted
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
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
                        width: parent.width * (root.isMuted ? 0 : Math.min(root.volumeValue, 100) / 100)
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
}
