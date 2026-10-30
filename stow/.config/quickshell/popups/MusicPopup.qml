import QtQuick
import Quickshell
import ".."

PopupWindow {
    id: root
    readonly property bool active: ShellGlobals.openPopup === "music"

    // Stays permanently mapped (shrunk to 1x1 while idle) so the GL context is
    // not torn down on every hover open - same pattern as GlobalPopup / VolumeOsd.
    visible: ShellGlobals.primaryBarWindow !== null && !ShellGlobals.locked
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: 0
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 2
    implicitWidth: card.active ? (ShellGlobals.primaryBarWindow?.width ?? 1920) : 1
    implicitHeight: card.active ? Math.max(card.implicitHeight + 28, 120) : 1
    color: "transparent"
    grabFocus: false

    readonly property int bodyWidth: 360
    readonly property int flareMargin: 58

    function _targetX() {
        const barW = root.implicitWidth
        const bw = root.bodyWidth
        const centerX = ShellGlobals.musicButtonCenterX
        return Math.max(-flareMargin - 2, Math.min(centerX - bw / 2 - flareMargin, barW - bw - flareMargin + 2))
    }

    Connections {
        target: ShellGlobals
        function onOpenPopupChanged() {
            if (ShellGlobals.openPopup === "music")
                focusRetryTimer.restart()
        }
    }

    Timer {
        id: focusRetryTimer
        interval: 80
        repeat: true
        property int attempts: 0
        onTriggered: {
            attempts++
            const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
            p.onExited.connect(exitCode => {
                if (exitCode === 0)
                    MusicService.focusMusicSearch()
            })
            p.command = ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/focus-music-popup.sh"]
            p.running = true
            if (attempts >= 12)
                stop()
        }
        onRunningChanged: if (!running) attempts = 0
    }

    PopupCard {
        id: card
        open: root.active
        color: Theme.overlay
        borderWidth: 2
        borderColor: Theme.iris
        flareMargin: root.flareMargin
        maxHeight: 700
        targetBodyWidth: root.bodyWidth
        targetX: root._targetX()
        content: musicContent
        closeHover: ShellGlobals.musicHover
    }

    Loader {
        id: _warmup
        visible: false
        sourceComponent: musicContent
        onLoaded: Qt.callLater(() => { sourceComponent = null })
    }

    Component { id: musicContent; MusicPopupContent {} }
}
