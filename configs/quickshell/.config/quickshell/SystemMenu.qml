import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    // Window stays fixed-size and just snaps open/closed — RevealBox does
    // the actual grow/shrink animation as an in-process clip, which avoids
    // the flicker that comes from animating real X11 window geometry.
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: Math.max(8, Math.min(ShellGlobals.systemButtonCenterX - implicitWidth / 2, (ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth - 8))
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 4
    // SysMenuItem.implicitWidth is a fixed 200, plus RevealBox's default
    // 14px content margins on each side.
    implicitWidth: 228
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    function _run(args) {
        ShellGlobals.systemMenuOpen = false
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    RevealBox {
        id: revealBox
        open: ShellGlobals.systemMenuOpen
        color: Theme.overlay
        spacing: 0

        SysMenuItem { label: "Restart";           onClicked: root._run(["bash", "-c", "pkill obs; systemctl reboot"]) }
        SysMenuItem { label: "Suspend";           onClicked: root._run(["systemctl", "suspend"]) }
        SysMenuItem { label: "Update & Shutdown"; onClicked: root._run(["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/update-and-shutdown.sh"]) }
        SysMenuItem { label: "Shutdown";          onClicked: root._run(["bash", "-c", "pkill obs; systemctl poweroff"]) }
    }

    CloseOnExit {
        anchors.fill: revealBox
        onExited: ShellGlobals.systemMenuOpen = false
    }
}
